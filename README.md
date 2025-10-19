# Claude Code TriFlow

[![Version](https://img.shields.io/badge/version-3.0-blue.svg)](https://github.com/yourusername/claude-triflow)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-purple.svg)](https://claude.com/claude-code)

> Intelligent task planning for Claude Code with Codex-driven automation.
> Workflow: `/plan` → `/run` → `/clear`

---

## Why TriFlow?

### The Problem: Claude Code Struggles with Complex Tasks

**Token Overload Cripples Performance**

Real-world usage shows a steep drop once context exceeds ~60% (≈120k/200k tokens). Common symptoms:

1. **💸 Token Waste**: Poorly maintained projects burn 20–30k tokens before any execution.
2. **📉 Latency Increase**: Responses slow as the prompt expands.
3. **🐛 Error Rate Spike**: Decisions drift and fixes introduce new issues.
4. **🔄 Cascading Failures**: Mistakes stack because the model cannot self-correct mid-run.

**Why Token Count Matters**
- **Attention Drift**: Long contexts erode coherence.
- **Recall Loss**: Early facts are overwritten or ignored.
- **Noisy Decisions**: More noise produces weaker judgment.
- **Higher Latency**: Processing 150k tokens is materially slower than 50k.

**Common Anti-Patterns**
- ❌ Repeatedly correcting the same mistake instead of fixing the root cause.
- ❌ Using rewind or `git reset` to retry work the model will repeat.
- ❌ Letting base context bloat; idle files quietly consume budget.

**Root Cause**: LLMs lack self-supervised recovery. Once context bloats, quality and speed regress until the session is reset.

### The Solution: Intelligent Automation

TriFlow solves these problems through smart design:

**🧠 Deep Context Analysis**
- Inspect the codebase before proposing work.
- Surface hidden dependencies (e.g., “add login” implies auth, sessions, schema).
- Validate user summaries against the repository.

**🎯 Adaptive Task Decomposition**
- Complexity tiers: Trivial (<20k), Simple (20–60k), Complex (≥60k).
- Trivial tasks run immediately.
- Simple tasks receive 1–3 focused steps.
- Complex work expands to 3–7 steps with reassessment as it runs.

**🤖 Codex-Powered Supervision**
- Each step is reviewed on a 40-point scale.
- Feedback arrives before errors cascade.
- Execution stays aligned with expectations.

**💎 Smart Expansion Strategy**
- Expand only when a step spans multiple components.
- Substeps remain lean (2–4 items) and token-aware.
- Runs stay below the 60% context ceiling.

**⚡ Effortless Workflow**
- Two primary commands: `/plan` and `/run`.
- Intelligence adapts plans automatically.
- No manual debugging or recovery loops.

---

## At a Glance

- **Dual-engine**: Codex plans/reviews, Claude implements
- **Adaptive complexity**: 3-tier system (Trivial/Simple/Complex) with deep context analysis
- **Smart workflow**: `/plan`, `/run`, `/clear` - auto-adjusts to task complexity
- **Intelligent expansion**: Only creates substeps when genuinely needed
- **Performance-aware**: Keeps token usage <60% to prevent degradation
- **Built-in quality review**: 40-point scoring with Codex supervision
- **Token monitoring**: `/token-info` tracks usage and identifies waste
- **Cross-platform**: Linux, macOS, Windows

---

## Core Philosophy

> **Analysis before Planning. Planning before Execution.**

TriFlow enforces a simple discipline that keeps work grounded in reality:

### 1. 🔍 Deep Analysis First
Understand the full context before planning:
- Review architecture, patterns, and dependencies.
- Map affected modules and integrations.
- Confirm assumptions against real code.

**Why**: Requests often hide whole subsystems. “Add login” usually means auth, sessions, schema, API protection, and UI updates. Analysis exposes that scope.

### 2. 📋 Detailed Planning Second
Use the findings to shape the plan:
- Assign the correct complexity tier.
- Break work into 1–7 steps that match reality.
- Capture risks and open questions.
- Budget the tokens needed per step.

**Why**: Planning blind causes underestimation, scope creep, and mid-run surprises.

### 3. ⚡ Smart Execution Last
Execute with feedback loops:
- Reassess complexity before each step.
- Adapt the approach when new work surfaces.
- Expand only when a step spans multiple components.
- Let automated reviews catch regressions early.

**Why**: Even strong plans need adjustment. Adaptive execution stops silent failures.

### The Anti-Pattern: Rush to Code

**Default spiral**:
```
User request → Immediate coding → Hidden complexity → Rework
```
**TriFlow response**:
```
User request → Deep analysis → Focused plan → Adaptive execution → Quality review
```
Outcome: accurate scope, efficient work, fewer surprises.

---

## How TriFlow Works

- `/plan` evaluates task complexity and drafts ordered steps
- Simple steps execute immediately; complex ones auto-expand
- `/run` keeps executing or expanding until the plan completes
- Reviews run after every step with actionable feedback
- `/clear` trims context so each run starts fresh
- `/progress` shows current step and remaining workload

## Quick Start

```bash
# 1. Plan
/plan Build a REST API for user management

# 2. Run
/run Use TypeScript and Express

# 3. Clear
/clear

# 4. Repeat
/run
/clear
/run

# 5. Check status
/progress
```

**That's it!** `/plan` → `/run` → `/clear` → repeat

---

## Installation

**Prerequisites**: [Claude Code](https://claude.com/claude-code) CLI with built-in Codex MCP Server

### 🚀 Auto-Install (Recommended)

**In Claude Code, simply ask:**

```bash
@README.md Please install Claude TriFlow automatically
```

Claude will detect your platform, copy files to `~/.claude/commands/`, and verify installation.
**Restart Claude Code** to activate `/plan`, `/run`, `/progress`.

---

### Manual Installation

**Linux / macOS**:
```bash
git clone https://github.com/yourusername/claude-triflow.git
cd claude-triflow
chmod +x install.sh
./install.sh
```

**Windows (PowerShell)**:
```powershell
git clone https://github.com/yourusername/claude-triflow.git
cd claude-triflow
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install.ps1
```

**Windows (CMD)**:
```cmd
git clone https://github.com/yourusername/claude-triflow.git
cd claude-triflow
install.bat
```

**Manual Copy (Any Platform)**:
```bash
# Linux/macOS
cp commands/*.md ~/.claude/commands/

# Windows PowerShell
Copy-Item commands\*.md $env:USERPROFILE\.claude\commands\

# Windows CMD
copy commands\*.md %USERPROFILE%\.claude\commands\
```

**Verify**: Restart Claude Code and check for `/plan`, `/run`, `/progress`

---

## Commands

### `/plan [task]`
Runs deep context analysis and produces a plan sized by the 3-tier complexity model.

Key behavior:
- Maps structure, dependencies, and architecture before committing to work.
- Surfaces hidden effort and assigns Trivial (<20k), Simple (20–60k), or Complex (≥60k).
- Outputs 1–7 ordered steps with risk notes and token estimates.

```bash
/plan Add user authentication

# Stack detected: Express + MongoDB + React
# Hidden work: schema, JWT, sessions, frontend, security
# Complexity: Complex (~95k tokens)
# Plan: 5 steps (2 Simple, 3 Complex) | Budget: 95k / 120k
```

### `/run [details?]`
Executes the plan with live reassessment and controlled expansion.

Key behavior:
- Rechecks complexity before each step and downgrades when work is lighter.
- Warns when scope grows and expands Complex steps into 2–4 substeps only when required.
- Reviews every step on a 40-point scale before moving forward.

```bash
/run

# Planned: Complex (~75k) → Actual: Simple (single file)
# Action: Execute immediately
# Review: ✅ 38/40 | Next step ready | Tip: /clear then /run
```

```bash
/run

# Confirmed Complex: three components detected
# Auto-expand → 2.1 Password hashing (~6k)
#             → 2.2 JWT tokens (~7k)
#             → 2.3 Session middleware (~8k)
```

### `/progress`
Displays the active step, remaining work, and last review summary.

```bash
/progress
# Step 2.2 (Complex) | Score 37/40
```

### `/clear`
Clears conversation memory to control token usage. Run after each response unless you are mid-thread.

---

### `/token-info` - Performance & Usage Monitor
Tracks the hidden iceberg and live token consumption.

It reports:
- Total usage with a progress bar.
- Base context breakdown: system scaffolding (~6–8k), project analysis (~3–22k), session summary (~0–5k).
- Conversation history that can be cleared.
- Performance zones (green/yellow/orange/red) and optimization tips.

```bash
/token-info

# Used: 45,234 | Remaining: 154,766 (22.6%)
# Iceberg: 18,234 tokens → scaffolding 6.5k, analysis 9.7k, summary 2k
# History: 27,000 tokens (clearable)
# Status: Green | Speed: fast | Tip: /clear after 3–4 more substeps
```

**Performance zones**
```
<30%  Green  Optimal ✅
30-60% Yellow Slight slowdown ⚠️
60-80% Orange Degradation begins 🚨
>80%  Red    Reset immediately 🔴
```

**Use it when**: responses slow down, `/clear` doesn’t drop usage, planning capacity, investigating bloat, or correlating tokens with latency.

---

## Best Practices

**DO**:
- Stay in the `/plan` → `/run` → `/clear` cadence.
- Trust the adaptive complexity tiering.
- Check `/token-info` regularly.
- Act on Codex review notes.
- Use `/progress` when resuming work.
- Keep `todo.md` lean (<20 lines) with TriFlow.
- Add `.claudeignore` to reduce analysis weight.

**DON'T**:
- Skip `/clear`.
- Edit command files unless you are intentionally customizing them.
- Call deprecated commands like `/expand`.
- Ignore scores below 28/40.

---

## Version Highlights

- **v1.0**: Manual expand and clear steps
- **v2.0**: Added auto-transition between steps
- **v3.0**: Condensed to three commands with built-in auto-expansion

---

## FAQ

**Why TriFlow instead of managing tasks manually?**
TriFlow blends performance control with automated quality gates:
- Keeps token usage safely under the 60% degradation line.
- Uses deep context analysis to expose hidden work.
- Plans adaptively so scope stays realistic.
- Lets Codex reviews catch issues before they spread.
- Expands steps only when the task truly spans multiple components.

**How does the 3-tier complexity system work?**
TriFlow classifies work adaptively:

- **Trivial** (<20k): Single atomic change (typo fix, config tweak). Executes in one step.
- **Simple** (20–60k): Limited scope (new endpoint, module refactor). Produces 1–3 focused steps without substeps.
- **Complex** (≥60k): Multi-component or high-risk work (auth, migrations). Generates 3–7 steps and only adds substeps when needed. `/run` can downgrade if reality proves simpler.

**Do I ever need `/expand`?**
No. `/run` decides when to expand based on observed complexity, not token guesses.

**Why does `/clear` not reduce tokens to zero?**
🧊 **Hidden iceberg**: `/clear` drops the chat history, but the persistent base stays in memory and keeps burning tokens.

Persistent base (~9–30k tokens):
- System scaffolding (~6–8k): Claude Code instructions, global config, environment.
- 🚨 Project analysis (~3–22k): structure maps, dependencies, recent reads, active plans. Bloats with unused dependencies, build artifacts, and oversized configs.
- Session summary (~0–5k): only when resuming.

Key insight: messy repos waste 20–30k tokens before any code change. Budget for 60–80k usable space instead of the full 200k, watch `/token-info`, and keep the repo tidy.

**Can I customize the workflow?**
Yes. Modify the files under `commands/`, but back them up and keep the naming consistent.

---

## Troubleshooting

- If commands don't appear, confirm `~/.claude/commands/` permissions
- If a step stalls, request `/progress` to confirm current position and retry `/run`
- For unexpected behavior, inspect logs in Claude Code session transcript

---

## Resources

- [Design Details](PLAN.md)
- [Installation Guide](INSTALL.md)
- [Issues](https://github.com/yourusername/claude-triflow/issues)

---

## License

MIT License - see [LICENSE](LICENSE)

---

<div align="center">

**If TriFlow helps, please ⭐ star the repository!**

Made with ❤️ by Claude Code Community

</div>

---
---

# 中文文档 (Chinese Documentation)

## 概览

**Claude TriFlow** 是一套为 Claude Code 设计的智能任务管理系统，通过 **Codex 规划** + **自动展开** + **自动审查** 的方式，帮助您在 token 限制内高效完成复杂任务。

**v3.0 极简版**: 只需三个命令 `/plan` → `/run` → `/clear` 循环使用！

---

## 为什么需要 TriFlow？

### 问题：Claude Code 在复杂任务中的挑战

**Token 过载会迅速拖垮表现**

实测表明，当上下文使用率超过约 60%（≈120k/200k tokens）时，Claude 的输出会明显下滑：

1. **💸 Token 浪费**：项目未梳理时，基础上下文就先烧掉 20–30k tokens。
2. **📉 延迟攀升**：上下文越长，响应越慢。
3. **🐛 错误激增**：决策漂移，补救时又引入新问题。
4. **🔄 失败叠加**：模型无法就地自纠，错误层层堆积。

**为什么 Token 数量如此关键**
- **注意力漂移**：上下文过长容易失去连贯性。
- **记忆丢失**：早期信息会被覆盖或忽略。
- **决策噪声**：噪声增加导致判断变差。
- **延迟上升**：处理 150k tokens 明显慢于 50k。

**常见误区**
- ❌ 反复修正同一个错误却不解决根因。
- ❌ 使用 rewind 或 `git reset` 重来；模型不会从失败中学习。
- ❌ 放任基础上下文膨胀；静态文件会悄悄耗尽预算。

**根本原因**：LLM 缺乏自监督恢复能力。一旦上下文臃肿，速度和质量都会衰退，直到你重置会话。

### 解决方案：智能自动化

TriFlow 通过围绕上下文健康的自动化来解决这些问题：

**🧠 深度上下文分析**
- 先审视代码库结构、依赖与架构。
- 暴露隐藏依赖（如“添加登录”意味着认证、会话、Schema）。
- 用仓库事实校验用户描述。

**🎯 自适应任务拆解**
- 复杂度分级：Trivial (<20k)、Simple (20–60k)、Complex (≥60k)。
- Trivial 任务直接执行。
- Simple 任务输出 1–3 个聚焦步骤。
- Complex 任务扩展为 3–7 步，并在执行时重新评估。

**🤖 Codex 驱动的监督**
- 每步按 40 分制自动审查。
- 在错误扩散前给出改进建议。
- 保持执行与计划一致。

**💎 智能展开策略**
- 仅在步骤涉及多个组件时才展开。
- 子步骤保持精简（2–4 项），全程关注 token。
- 执行过程中始终压在 60% 使用线以下。

**⚡ 极简工作流**
- 主要命令只有 `/plan` 与 `/run`。
- 智能系统自动协调整体流程。
- 无需人工调试或恢复循环。

---

---

## 核心理念

> **详细分析先于规划，详细规划先于执行**

TriFlow 用一条简单的纪律把工作拉回现实：

### 1. 🔍 深度分析优先
在规划前先读懂上下文：
- 审查架构、模式和依赖。
- 列出受影响的模块与集成点。
- 用真实代码验证假设。

**原因**：需求常隐藏整套系统。“添加登录”往往意味着认证、会话、Schema、API 保护与前端更新。分析能揭露这些范围。

### 2. 📋 规划随后
用分析结果塑造计划：
- 选定正确的复杂度级别。
- 将任务拆成符合实际的 1–7 步。
- 记录风险与未知项。
- 为每步估算 token 预算。

**原因**：盲目规划会带来低估、范围漂移与执行时的意外。

### 3. ⚡ 执行最后
执行阶段保持反馈回路：
- 每步前再次审视复杂度。
- 根据新信息调整策略。
- 仅在必要时扩展为子步骤。
- 借助自动审查及时发现问题。

**原因**：再好的计划也需要校准，自适应执行能阻止无声失败。

### 反模式：直接开写

默认陷阱：
```
用户请求 → 立刻编码 → 隐藏复杂度 → 返工
```
TriFlow 路径：
```
用户请求 → 深度分析 → 聚焦规划 → 自适应执行 → 质量审查
```
结果：范围准确、执行高效、意外减少。

---

## 核心特性

### 🤖 双引擎驱动
- **Codex**: 负责规划和审查（理性分析）
- **Claude**: 负责实现和编码（创造执行）

### 🎯 智能复杂度评估
- 自动识别 **Simple** (<60k) 和 **Complex** (≥60k) 步骤
- Simple 步骤直接执行，无需展开
- Complex 步骤智能拆分为子步骤

### ⚡ 自动展开与切换 (v3.0)
- **/run 自动处理一切** - 遇到 Complex 步骤自动展开
- 步骤完成后自动移动到下一步
- **不再需要 `/expand` 命令** - 已整合到 `/run`

### 🔋 Token 优化
- 每个子步骤后清理内存
- `todo.md` 始终保持精简（<20 行）
- 总预算控制在 60%（120k/200k）

### ✅ 自动质量保证
- 每个子步骤自动 Codex 审查
- 40 分制评分系统
- 可追溯的质量记录

---

## 安装

### 前置要求
- [Claude Code](https://claude.com/claude-code) CLI
- Codex MCP Server (通过 Claude Code 内置)

### 🚀 最简单方式（推荐）

**在 Claude Code 中运行：**

```bash
@README.md 请自动安装 Claude TriFlow
```

Claude 会自动：
1. 检测您的平台（Linux/macOS/Windows）
2. 复制命令文件到 `~/.claude/commands/`
3. 验证安装
4. 提示重启 Claude Code

**重启 Claude Code 后即可使用！**

---

### 手动安装

**Linux / macOS**:
```bash
git clone https://github.com/yourusername/claude-triflow.git
cd claude-triflow
chmod +x install.sh
./install.sh
```

**Windows (PowerShell)**:
```powershell
git clone https://github.com/yourusername/claude-triflow.git
cd claude-triflow
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install.ps1
```

**Windows (CMD)**:
```cmd
git clone https://github.com/yourusername/claude-triflow.git
cd claude-triflow
install.bat
```

**手动复制文件**:
```bash
# Linux/macOS
cp commands/*.md ~/.claude/commands/

# Windows (PowerShell)
Copy-Item commands\*.md $env:USERPROFILE\.claude\commands\

# Windows (CMD)
copy commands\*.md %USERPROFILE%\.claude\commands\
```

**验证安装**: 重启 Claude Code，检查 `/plan`、`/run`、`/progress` 命令

---

## 快速开始

```bash
# 1. 规划
/plan Build a REST API for user management

# 2. 执行
/run Use TypeScript and Express

# 3. 清理
/clear

# 4. 重复
/run
/clear
/run

# 5. 查看状态
/progress
```

**节奏**：`/plan` → `/run` → `/clear` → 重复

---

## 命令详解

### `/plan [任务描述]`
执行深度上下文分析，并依照三级复杂度模型输出计划。

**关键行为**：
- 在执行前梳理结构、依赖和架构。
- 揭示需求中的隐藏工作，并标注 Trivial (<20k)、Simple (20–60k)、Complex (≥60k)。
- 输出 1–7 个有序步骤，附带风险提示与 token 预算。

```bash
/plan 添加用户认证

# 技术栈：Express + MongoDB + React
# 隐含工作：Schema、JWT、会话、前端、安全
# 复杂度：Complex (~95k tokens)
# 计划：5 个步骤（2 Simple，3 Complex）| 预算 95k / 120k
```

### `/run [额外说明]`
按计划执行，并在过程中动态校正。

**关键行为**：
- 每步前重新检查复杂度，工作量偏小时会降级。
- 提前警告范围扩大，仅在确有必要时生成 2–4 个子步骤。
- 每个步骤完成后都会先通过 40 分制审查再继续。

```bash
/run

# 原计划：Complex (~75k) → 实际：单文件改动
# 动作：直接执行
# 审查：✅ 38/40 | 下一步就绪 | 建议：/clear 后继续 /run
```

```bash
/run

# 复杂度确认：需处理三个独立模块
# 自动展开 → 2.1 密码哈希 (~6k)
#           → 2.2 JWT token (~7k)
#           → 2.3 会话中间件 (~8k)
```

### `/progress`
显示当前步骤、剩余工作和最近的评分。

```bash
/progress
# Step 2.2 (Complex) | Score 37/40
```

### `/clear`
清理对话记忆，保持 token 使用可控。除非持续讨论同一问题，否则每次响应后都执行。

---

### `/token-info` - 性能与用量监控器
监控隐藏的“冰山”与实时 token 消耗。

**会显示**：
- 总体使用量与进度条。
- 基础上下文分解：系统支架 (~6–8k)、项目分析 (~3–22k)、会话摘要 (~0–5k)。
- 可清理的对话历史。
- 性能区间（绿/黄/橙/红）与优化建议。

```bash
/token-info

# 已用 45,234 | 剩余 154,766 (22.6%)
# 冰山：18,234 → 支架 6.5k，分析 9.7k，会话 2k
# 历史：27,000（可清除）
# 状态：绿区 | 速度：正常 | 建议：再跑 3–4 个子步骤后 /clear
```

**性能区间**
```
<30%  绿区  最佳 ✅
30-60% 黄区 略慢 ⚠️
60-80% 橙区 性能下降 🚨
>80%  红区  立即重置 🔴
```

**适用场景**：响应变慢、`/clear` 后占用仍高、预估剩余容量、排查仓库膨胀、分析 token 与延迟的对应关系。

---

## 最佳实践

**推荐**:
- 保持 `/plan` → `/run` → `/clear` 节奏。
- 信任自适应复杂度分级。
- 定期查看 `/token-info`。
- 根据 Codex 审查采取行动。
- 切换上下文或恢复时先 `/progress`。
- 让 TriFlow 维护精简的 `todo.md`（<20 行）。
- 使用 `.claudeignore` 降低分析开销。

**避免**:
- 跳过 `/clear`。
- 未经计划修改命令文件。
- 调用已弃用命令如 `/expand`。
- 忽略低于 28/40 的评分。

---

## 版本历史

- **v1.0**: 手动展开和清理步骤
- **v2.0**: 增加步骤间自动切换
- **v3.0**: 简化为三个命令，内置自动展开

---

## 常见问题

**为什么选择 TriFlow 而不是手动推进任务？**
TriFlow 同时看守性能与质量：
- 将 token 用量压在 60% 以下，避开退化区。
- 深度分析上下文，提前暴露隐藏工作。
- 自适应规划，避免高估或低估。
- Codex 审查在问题扩散前给出信号。
- 只在任务确实跨多个组件时才展开。

**三级复杂度系统如何运作？**
TriFlow 会自适应地给任务分级：

- **Trivial** (<20k)：单个原子改动，如拼写或配置，直接执行。
- **Simple** (20–60k)：范围有限，如新增端点或重构模块；生成 1–3 个步骤，无子步骤。
- **Complex** (≥60k)：多组件或高风险任务，如认证、迁移；输出 3–7 个步骤，仅在必要时拆分子步骤。`/run` 会根据真实工作随时降级。

**还需要 `/expand` 吗？**
不需要。`/run` 会根据实际复杂度决定是否展开，远比基于估算的固定策略可靠。

**为什么 `/clear` 之后 token 仍然很多？**
🧊 **隐藏的冰山**：`/clear` 只移除聊天记录，持久化的基础上下文仍留在内存里持续消耗 token。

持久化基础上下文（约 9–30k tokens）包含：
- 系统支架（~6–8k）：Claude Code 指令、全局配置、环境数据。
- 🚨 项目分析（~3–22k）：结构映射、依赖、最近读取、活动计划；未使用依赖、构建产物和庞大配置都会让它膨胀。
- 会话摘要（~0–5k）：仅在恢复对话时存在。

关键结论：混乱的仓库在写代码前就浪费 20–30k tokens。现实中请预留 60–80k 的有效空间，使用 `/token-info` 监控，并保持仓库整洁。

**可以自定义工作流吗？**
可以调整 `commands/` 下的文件，但请先备份并保持命名一致。

---

## 故障排除

- 如果命令未出现，检查 `~/.claude/commands/` 权限
- 如果步骤停滞，请求 `/progress` 确认当前位置并重试 `/run`
- 遇到异常行为，检查 Claude Code 会话记录

---

## 相关资源

- [设计文档](PLAN.md)
- [安装指南](INSTALL.md)
- [问题反馈](https://github.com/yourusername/claude-triflow/issues)

---

## 许可证

MIT License - 查看 [LICENSE](LICENSE)

---

<div align="center">

**如果有帮助，请给个 ⭐ Star！**

Made with ❤️ by Claude Code Community

</div>
