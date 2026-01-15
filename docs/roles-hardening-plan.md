# 角色机制硬约束方案 (Roles Hardening Plan)

## 1. 概述

### 背景与目标
目前 `cca` (Claude Code AutoFlow) 依赖用户手动调用 `/tp` 或 `/tr` 来触发基于角色的任务执行。我们的目标是让**普通任务**（自然语言指令）也能自动按 Roles 委派执行（例如：Claude 规划 -> Codex 执行），而无需显式调用特定 Skill。

### 核心问题
当前机制严重依赖 `CLAUDE.md` 中的 Prompt 提示（软约束）。在实际使用中，Claude 可能会忽略这些规则，直接尝试修改文件或执行命令，导致“角色委派”失效。

## 2. 方案对比

为了实现从"软约束"到"硬约束"的转变，我们评估了以下三种方案：

| 档位 | 方案名称 | 核心机制 | 稳定性 | 复杂度 | 评价 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **档1** | **CLAUDE.md + Hook注入** | 通过 Hook 在每次启动时注入系统级 Prompt，强调角色分工。 | 中 (软约束) | 最低 | 基础方案，可强化。 |
| **档2** | **工具权限 Allowlist** | 在 `.claude/settings.json` 中配置权限，禁用 Claude 的直接写/执行能力。 | ❌ 不可行 | 低 | **经测试验证：permissions配置不生效** |
| **档3** | **MCP Server 收口** | 开发专用的 MCP Server 接管所有 I/O，移除默认的文件系统工具。 | 最高 | 中 | 开发周期长，架构变动大。 |

## 3. 最终方案：档1强化版（Codex侧自解析Roles）

### 验证结论

经过实际测试，档2方案（permissions allowlist）**不可行**：
- 在 `.claude/settings.json` 中配置 `permissions.deny: ["Bash", "Write", "Edit"]`
- 测试结果：Bash命令仍然可以执行，配置不生效
- 结论：Claude Code 可能不支持这种 permissions 配置方式

### 最终方案原理

把"按roles路由executor"从Claude的自觉挪到**`/file-op`内部（Codex侧）强制执行**：

1. **Hook注入**：`cca-roles-hook` 在首次工具调用时注入roles信息
2. **Codex自解析**：Codex收到FileOpsREQ后，**必须自己读取roles配置**决定executor
3. **硬约束点**：executor路由不再依赖Claude是否传`constraints.executor`

### 效果

- 即使Claude偏离或忘了带字段，只要走`/file-op`，执行器路由就是稳定的
- 普通任务通过CLAUDE.md引导走`/file-op`，复杂任务走`/tp /tr`

## 4. 实现步骤

### 4.1 重构 `cca-roles-hook`
将 Hook 脚本统一为 Python，并实现“结构化输出 + 配置签名 marker”，保证：
- 仅在**首次工具调用**且 roles 配置发生变化时输出
- 输出为单行可机读格式，便于稳定注入上下文

**新版本要点：**
1.  **结构化输出**: 输出格式固定为 `[CCA_ROLES_V1] {JSON单行}`，便于 Claude 解析。
2.  **配置签名**: 基于候选 roles 文件的 `mtime/size` 生成签名；签名不变则不重复输出，签名变化则重新输出。
3.  **Roles 优先级逻辑**:
    *   Priority: `Project` (.autoflow/roles.json) > `Default`。

### 4.2 强化 `/file-op`（Codex 侧自解析 roles）
将“按 roles 路由 executor”的硬约束点放到 `/file-op` 的执行端（Codex）：
- Codex 收到 FileOpsREQ 后必须自己读取并解析 roles（按优先级），决定 executor
- 不依赖 Claude 是否传 `constraints.executor`
- 当 executor=opencode 时，Codex 通过 `oask` 指导 OpenCode 执行并审查结果

### 4.3 更新 `CLAUDE.md` 默认工作流规则
将普通任务的默认路径写清楚（最简规则即可）：
- 任何涉及仓库文件修改或命令执行 → 必须走 `/file-op`
- 任何需要交叉审查 → 走 `/review`

## 5. 关键风险与验证

### 风险点：普通任务可能绕过 `/file-op`
由于 Claude Code 不支持可用的 permissions allowlist（档2不可行），本方案的“硬约束”落点是 `/file-op` 端自解析 roles；但前提仍是普通任务进入 `/file-op` 路径。

**缓解策略（保持简单）**：
- `CLAUDE.md` 给出最短的默认工作流规则（改文件/跑命令一律 `/file-op`）
- `cca-roles-hook` 在首次工具调用时注入结构化 roles（降低偏离概率）
- `/file-op` 执行端强制自解析 roles（即使 Claude 忘带 executor 也能正确路由）

### 风险点：roles 配置错误/不可读
- JSON 非法、schemaVersion 不匹配、enabled=false 等会导致回退默认 executor=codex
- 需要在 Hook 输出中包含 `source` 字段，方便定位生效来源

### 验证步骤
1.  **Hook 验证**: 启动新会话并触发任意一次工具调用，确认 Hook 首次输出为单行 `[CCA_ROLES_V1] {json}`。
2.  **签名失效**: 修改任一 roles 文件后再次触发工具调用，确认 Hook 会重新输出（签名变化）。
3.  **路由测试 (codex)**: 设置 `executor=codex`，通过 `/file-op` 执行一个最小变更，确认 Codex 直执行。
4.  **路由测试 (opencode)**: 设置 `executor=opencode`，通过 `/file-op` 执行一个最小变更，确认 Codex 通过 `oask` 监督 OpenCode 执行并返回 FileOpsRES。
5.  **回退测试**: 写入非法 JSON/禁用 enabled，确认回退到默认 executor=codex，并从 Hook 的 `source` 可看出回退原因（或至少看出未命中配置）。

## 6. 附录

### 附录 A: cca-roles-hook 输出示例

```text
[CCA_ROLES_V1] {"proto":"cca.roles.v1","source":"project:.../.autoflow/roles.json","repoRoot":"/path/to/repo","roles":{"schemaVersion":1,"enabled":true,"executor":"opencode","reviewer":"gemini","documenter":"gemini","designer":["claude","codex"]}}
```
