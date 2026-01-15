# AutoFlow Run

Execute current step while Claude stays in plan mode and Codex performs all file I/O.

**File formats**: See `~/.claude/skills/docs/formats.md`
**Protocol**: See `~/.claude/skills/docs/protocol.md`

---

## Execution Flow

**Auto-loop daemon**: started by `/tp` (`bash ~/.claude/skills/tr/scripts/autoloop.sh start`). `/tr` should assume it is running and only ensure the finalize request doesn't stop it.

### 1.0 Ensure Plan Mode

Plan mode is optional. If you prefer structured exploration, you can switch via `/mode-switch plan`.

### 1. Sync Current State (Codex)

Claude does not read/modify repo files directly. Request Codex to:
1) read `state.json`
2) validate `current`
3) enforce attempt limits
4) (if proceeding) increment attempts and persist back to `state.json`
5) return a compact step context for design

Call `/file-op` with `FileOpsREQ`:
- Template: `../templates/preflight.json`

Interpret `FileOpsRES`:
- If no plan → show `No plan. Use /tp first.` → Stop
- If `current.type == "none"` → All done → Show summary → Stop
- If attempts exceeded → request `autoflow_state_mark_blocked` with a reason → Stop
- Otherwise use `data.stepContext` + `data.state.current` for Step Design

### 1.5 Resolve Roles Config (P1)

Goal: support `reviewer` / `documenter` / `designer` routing, and allow `executor` switching between `codex` and `opencode`.

Config locations:
1) `<repo>/.autoflow/roles.json`
2) Defaults

Minimal schema (P0):
```json
{
  "schemaVersion": 1,
  "enabled": true,
  "executor": "codex|opencode",
  "reviewer": "codex|gemini",
  "documenter": "codex|gemini",
  "designer": ["claude", "codex|gemini"],
  "searcher": "claude|codex|opencode|gemini",
  "web_searcher": "claude|codex|opencode|gemini",
  "repo_searcher": "claude|codex|opencode|gemini",
  "repo_search_enforced": false,
  "git_manager": "claude|codex|opencode|gemini"
}
```

Rules:
- If `enabled != true` or `schemaVersion != 1` → ignore config (use defaults)
- Default roles if nothing configured:
  - `executor = "codex"`
  - `reviewer = "codex"`
  - `documenter = "codex"`
  - `designer = ["claude", "codex"]`
  - `searcher = "codex"` (legacy)
  - `web_searcher = "codex"`
  - `repo_searcher = "codex"` (enforced only when `repo_search_enforced=true`; covers Grep/Glob and repo-search Bash like `rg`/`git grep`)
  - `git_manager = "codex"`
- Executor validation:
  - Allow `executor = "codex"` or `executor = "opencode"`
  - Otherwise → fall back to `codex`

Implementation detail: Claude must not read repo files directly; request reads via `/file-op` (`read_file`) and parse JSON locally.

### 2. Step Design (Role-Routed)

If `designer` resolves to `["claude","codex"]` (default): invoke `/dual-design` skill:

```
design_type: step
requirement: [current step title]
context: [task objective, relevant files, dependencies]
```

This executes:
1. Claude independent step design
2. Codex independent step design
3. Merge discussion (1-2 rounds)

Returns merged approach with: `approach`, `doneConditions`, `risks`, plus split decision (`needsSplit`/`splitReason`/`proposedSubsteps`).

If `designer` resolves to `["claude","gemini"]`:
1) Claude produces the "Claude independent step design" as usual.
2) Ask Gemini for an independent design:
   - `/ask-gemini "Independent step design:\n\nStep: ...\nContext: ...\nReturn JSON only with keys: approach, doneConditions, risks, needsSplit, splitReason, proposedSubsteps (optional)."`
3) Claude merges Claude+Gemini into the same merged output schema used above.

### 3. Split Check (Before Execution)

After the Dual Design merge, decide whether this step must be split into substeps:

- If `needsSplit=false` → continue to Step 4 (execution path)
- If `needsSplit=true` → validate and apply split, then skip execution and jump to Step 9 (Finalize output)

Validation rules for `proposedSubsteps`:
- Count: 3-7
- Atomic: single action each
- No overlap; correct order

If valid, apply split via `/file-op` (use `data.state.current.stepIndex` from Preflight):
- Template: `../templates/split.json`

Then go to Step 9 (Finalize) and output the split result (no execution performed).

### 4. Build Step FileOpsREQ (Execution)

Based on merged approach:
- Build `FileOpsREQ` JSON (see `~/.claude/skills/docs/protocol.md`)
- Include agreed done conditions
- Note identified risks

Key rule: Codex may modify code and artifacts needed to satisfy done conditions, but must **not** advance the step to `done` until Claude approves in Review.

### 5. Send FileOpsREQ (FileOps)

Send the constructed FileOpsREQ via `/file-op`:

```
/file-op <the FileOpsREQ JSON>
```

(`/file-op` handles `cask` + `TaskOutput`)

### 6. Execute (Executor Routing)

- If `executor == "codex"`:
  - Codex directly executes FileOpsREQ operations and returns FileOpsRES.
- If `executor == "opencode"`:
  - Codex uses the internal `oask` skill to call OpenCode.
  - Codex acts as supervisor:
    - Translate FileOpsREQ ops into OpenCode-friendly instructions
    - Guide OpenCode step-by-step to apply changes and run commands
    - Review OpenCode results and validate against done conditions
    - If fixes are needed, guide OpenCode to iterate (respect `constraints.max_attempts`)
  - Codex returns the final FileOpsRES (JSON only) back to Claude.

### 7. Handle FileOpsRES (Codex or OpenCode)

**status = ok** → Go to Review

**status = ask** → Show questions to user → Re-run

**status = fail** → Request `autoflow_state_mark_blocked` with `fail.reason` → Stop

Note: `status = split` should be handled by Step 3 (Split Check). Treat unexpected `split` here as `fail` and re-run /dual-design to decide `needsSplit`.

When `executor == "opencode"`:
- FileOpsRES is still returned by Codex, but Codex must include proof that OpenCode actually applied the changes:
  - Changed files list
  - Diff summary (or key hunks)
  - Commands executed (if any)
- If results don't match `done` conditions, Codex must guide OpenCode to fix and re-run within `constraints.max_attempts`.

### 8. Review (Claude + Codex)

Invoke `/review` skill:

```
/review step
  target: [step title]
  doneConditions: [from dual-design output]
  changedFiles: [from FileOpsRES]
  proof: [execution summary]
```

See `../../review/references/flow.md` for full flow (Claude assessment → role-routed cross-review → Final decision).

Output: Review result with verdict (PASS/FIX/BLOCKED).

### 8.5 Test (Optional)

**Claude 判断是否需要测试**：
根据步骤性质判断：
- 代码修改 → 通常需要测试
- 配置/文档变更 → 通常不需要
- 重构 → 需要回归测试

如果需要测试，发送测试任务给 Codex：

```
Bash(cask "Run tests for this change:

Step: [step title]
Changed files: [list]
Test scope: [unit/integration/e2e]

Execute relevant tests and report:
1. Test command(s) executed
2. Pass/Fail summary
3. Any failures with details", run_in_background=true)
```

**Claude 审查测试结果**：
- All pass → Continue to Finalize
- Failures → 分析原因，决定：
  - 修复问题 (Back to step 5 with fix)
  - 标记为已知问题 (Continue with note)
  - 阻塞 (Mark blocked)

**Final Decision** (based on Review + Test):
- Both PASS → Finalize
- Either FIX → Merge fix items → Back to step 5 (max 1 retry)
- Disagreement → Claude makes final call with explanation

### 9. Finalize (Codex)

If Step 3 applied a split (`needsSplit=true`):
- Output: `Split applied. Next: first substep. Use /tr (autoloop will trigger if running).`
- Do not mark the step `done` (no execution happened yet).

If PASS (execution path), ask Codex to:
1) mark current step/substep `status: "done"` and advance `current`
2) regenerate `todo.md` from `state.json`
3) append completion entry to `plan_log.md`

Send `FileOpsREQ` with `purpose: "finalize_step"` via `/file-op`. Codex returns `FileOpsRES` JSON only.

Auto-loop requirement (reliable next-step trigger):
- After finalizing, Codex must run the auto-loop trigger (see `autoflow_auto_loop` in `~/.claude/skills/docs/protocol.md`; implemented as an explicit `run` op).
- If there are remaining steps, it must trigger the next `/tr` automatically using `lask`.
- It must be executed via the FileOpsREQ protocol (no manual copy/paste).

Recommended: combine finalize + auto-loop in one request (ops execute in order):
- Template: `../templates/finalize.json`

Output result:
- If more steps: `Step N complete. Next: [title]. Use /tr`
- If all done: `Task complete!` + acceptance checklist → Continue to Step 10 (Final Review)

### 10. Final Review (Task Completion Only)

**触发条件**：当 Step 8 Finalize 后检测到所有步骤已完成（`current.type == 'none'`）时执行此步骤。

#### 10.1 全流程回顾审查

Invoke `/review` skill with task mode:

```
/review task
  target: [task name from state.json]
  doneConditions: [acceptance criteria]
  changedFiles: [all files changed during task]
  proof: [all step summaries]
```

See `commands/review/flow.md` for full flow.

Output: Task-level review result.

#### 10.2 问题处理决策

根据审查结果：

- **无问题** → 进入 9.3 总结报告
- **小问题**（typo, minor fix）→ 直接让 Codex 修复，可选回 7.5 测试，然后进入 9.3
- **中等问题**（需要 1-2 个额外步骤）→ 追加步骤到当前任务：
  1. Claude 设计 1-2 个修复步骤
  2. 调用 `/file-op` 追加步骤到 `state.json`：
     - Template: `../templates/append-steps.json`
  3. 继续执行 `/tr` 完成追加的步骤
  4. 完成后重新进入 Step 9
- **较大问题**（需要 >2 个步骤）→ 创建 Follow-up 任务：
  1. 在 final report 中记录待解决问题
  2. 提示用户：「发现 N 个较大问题，建议创建新任务：/tp [follow-up description]」
  3. 进入 9.3 完成当前任务报告
- **需求本身不合理** → 记录原因，跳过修复，进入 9.3

#### 10.3 撰写总结报告

Claude 规划报告结构，并根据 `documenter` 生成 `reportContent`：
- `documenter = "codex"` (default): Claude 直接生成 `reportContent`
- `documenter = "gemini"`: Claude 先调用 `/ask-gemini` 生成 `reportContent`（markdown），再交给 Codex 写入文件

Codex 将 `reportContent` 写入 `final/` 文件夹：

- Template: `../templates/final-report.json`

**报告内容结构**：
- Task Overview (任务概述)
- Implementation Summary (实现摘要)
- Steps Executed (执行步骤列表)
- Key Decisions (关键决策)
- Issues Encountered & Resolutions (遇到的问题及解决)
- Final Verification Results (最终验证结果)
- Recommendations (后续建议，如有)

---

## Principles

1. **Shortest path**: Execute directly, split only when necessary
2. **Binary review**: PASS or FIX, no scoring
3. **Limited iterations**: Max 2 per step
4. **Auto-advance**: State transitions via file updates
