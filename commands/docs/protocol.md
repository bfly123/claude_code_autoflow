# TriFlow Communication Protocol

This protocol is designed for the "Claude stays in plan mode, Codex does all file I/O" architecture.

---

## FileOpsREQ (Claude → Codex)

Codex executes a list of explicit operations (`ops`) and returns `FileOpsRES`.

```json
{
  "proto": "triflow.fileops.v1",
  "id": "S2",
  "purpose": "execute_step|write_plan_files|finalize_step|read_state|split_step",
  "summary": "1 sentence intent for humans",
  "constraints": {
    "no_network": false,
    "writable_roots": ["."],
    "max_attempts": 2
  },
  "done": ["condition 1", "condition 2"],
  "ops": [
    { "op": "read_file", "path": "state.json" },
    { "op": "write_file", "path": "todo.md", "content": "..." },
    { "op": "write_json", "path": "state.json", "value": { "k": "v" } },
    { "op": "apply_patch", "patch": "*** Begin Patch\\n*** Update File: a.txt\\n@@\\n-Old\\n+New\\n*** End Patch\\n" },
    { "op": "run", "cmd": "pytest -q", "cwd": ".", "timeoutMs": 600000 }
  ],
  "report": {
    "changedFiles": true,
    "diffSummary": true,
    "commandOutputs": "on_failure|always|never"
  }
}
```

### Supported `ops`

- `read_file`: returns file content (use sparingly; prefer summaries for large files)
- `write_file`: overwrite full content
- `write_json`: write JSON value (pretty-printed, stable key ordering if possible)
- `apply_patch`: apply `apply_patch`-format patch
- `run`: run a shell command

### TriFlow domain `ops` (recommended)

These ops let Codex update `todo.md` / `state.json` / `plan_log.md` without Claude constructing full file contents.

- `triflow_plan_init`
  - input: `plan` (taskName, objective, context, constraints, steps[], finalDone[])
  - effect: writes `todo.md`, `state.json`, `plan_log.md`
- `triflow_state_preflight`
  - input: `path` (default `state.json`), `maxAttempts`
  - effect: loads state, validates `current`, increments attempts if allowed, persists state
  - output (in `data`): current step/substep context and a compact state summary
- `triflow_state_apply_split`
  - input: `stepIndex`, `substeps` (3-7 titles)
  - effect: writes substeps into `state.json`, regenerates `todo.md`
- `triflow_state_finalize`
  - input: `verification` (short), `changedFiles` (optional)
  - effect: marks current step/substep done, advances `current`, regenerates `todo.md`, appends `plan_log.md`
- `triflow_state_mark_blocked`
  - input: `reason` (short)
  - effect: marks current step/substep blocked, regenerates `todo.md`, appends `plan_log.md` (optional)
- `triflow_state_append_steps`
  - input: `steps` (1-2 titles), `maxAllowed` (default 2)
  - precondition: `current.type == 'none'` (task completed)
  - effect: appends steps to `state.json`, sets `current` to first new step, regenerates `todo.md`, appends to `plan_log.md`
  - error: if `steps.length > maxAllowed`, return `fail` with suggestion to create follow-up task
- `triflow_auto_loop` (explicit `run`-based)
  - goal: reliably trigger the next `/tr` without requiring Codex to "understand" a domain op
  - recommended op:
    ```json
    { "op": "run", "cmd": "python3 automation/autoloop.py --once", "cwd": ".", "timeoutMs": 600000 }
    ```
  - behavior (implemented by `automation/autoloop.py`):
    1) loads `state.json` and checks whether there are remaining steps
    2) reads the latest Claude session JSONL under `~/.claude/projects/<project-dir>/*.jsonl` (excluding `agent-*.jsonl`)
    3) finds the latest record with `message.usage` and estimates current context window using:
       - `usage.prompt_tokens` if present, else
       - `usage.input_tokens + usage.cache_creation_input_tokens + usage.cache_read_input_tokens` (plus prompt-token cache fields if present)
    4) gets `context_limit` from `~/.claude/ccline/models.toml` (pattern match) or falls back to `--context-limit`
    5) if usage% > 70%: runs `sleep 5 && lask '/clear' && sleep 2 && lask '/tr'`
       else: runs `sleep 5 && lask '/tr'`
    6) if no remaining work: returns without triggering (task complete)
  - note: `--once` prints a 1-line JSON summary to stdout (usable as `proof`)
  - output (in `data`): `taskComplete`, `next` (optional summary)

---

## FileOpsRES (Codex → Claude)

```json
{
  "proto": "triflow.fileops.v1",
  "id": "S2",
  "status": "ok|ask|fail|split",
  "changedFiles": ["todo.md", "state.json"],
  "data": {
    "state": { "current": { "type": "step", "stepIndex": 2, "subIndex": null } },
    "stepContext": "compact context for /dual-design"
  },
  "ops": [
    { "opIndex": 0, "status": "ok", "summary": "read state.json (1442 bytes)" },
    { "opIndex": 1, "status": "ok", "summary": "wrote todo.md" }
  ],
  "proof": {
    "commands": [
      { "cmd": "pytest -q", "exitCode": 0, "stdout": "", "stderr": "" }
    ],
    "notes": "verification evidence"
  },
  "split": { "substeps": [] },
  "ask": { "questions": [] },
  "fail": { "reason": "why failed", "hint": "how to fix" }
}
```

**IMPORTANT**: Codex must output ONLY JSON (no markdown, no prose) when responding to FileOpsREQ.

---

## Status Meanings

| status | meaning | required fields |
|--------|---------|-----------------|
| ok | success | `changedFiles`, `ops`, `proof` |
| split | need substeps | `split.substeps` |
| ask | need user info | `ask.questions` |
| fail | failed | `fail.reason` |

---

## Guardrails

| Rule | Value |
|------|-------|
| Max attempts per step | 2 |
| Max substeps | 3-7 |
| Max fix iterations | 1 |
| Substep refinement | 1 retry |

---

## cask Usage

Send FileOpsREQ:
```
/file-op <FileOpsREQ JSON>
```

Wait for response:
```
(handled by `/file-op`)
```

---

## Auto-Loop (Optional)

After step completion, delegate to Codex:
```
Bash(cask "Send /clear and /tr to Claude pane via lask.", run_in_background=true)
```
