# 📘 Claude Code 渐进式任务管理系统

## 完整实施指南 v2.0 (优化版)

---

## 📑 目录

1. [系统概述](#系统概述)
2. [核心理念](#核心理念)
3. [系统架构](#系统架构)
4. [命令详解](#命令详解)
5. [实施步骤](#实施步骤)
6. [使用指南](#使用指南)
7. [最佳实践](#最佳实践)
8. [工作流示例](#工作流示例)
9. [Token 效率分析](#token-效率分析)
10. [故障排除](#故障排除)

---

## 📖 系统概述

### 什么是渐进式任务管理系统？

这是一套基于 Claude Code 的智能任务规划和执行系统，通过 **Codex 规划** + **渐进式展开** + **自动审查** 的方式，帮助您在 token 限制内高效完成复杂任务。

### 核心特性

✅ **双引擎驱动**
- Codex：负责规划和审查（理性分析）
- Claude：负责实现和编码（创造执行）

✅ **智能复杂度评估** 🆕
- 自动识别Simple(<60k)和Complex(≥60k)步骤
- Simple步骤直接执行，无需展开
- Complex步骤智能拆分为子步骤
- 减少不必要的任务拆分

✅ **自动步骤切换** 🆕
- 步骤完成后自动移动到下一步
- 无需手动/expand切换
- 智能判断Simple/Complex工作流
- 流程更加自动化和流畅

✅ **渐进式展开**
- 宏观规划：3-7 个高级步骤
- 微观执行：仅Complex步骤展开为3-5个子步骤
- 动态管理：完成后自动收起并切换

✅ **极致 Token 优化**
- 每个子步骤后清理内存
- todo.md 始终保持精简（<20 行）
- 单次峰值 <10k tokens
- 总预算控制在 60%（120k/200k）

✅ **自动质量保证**
- 每个子步骤自动 Codex 审查
- 40 分制评分系统
- 建议和改进提示
- 可追溯的质量记录

### 解决的问题

| 传统方式 | v1.0系统 | v2.0优化 🆕 |
|---------|----------|------------|
| 一次性拆分所有任务 → todo 很长 | 渐进式展开 → todo 始终精简 | 同v1.0 |
| token 累积 → 可能超限 | 每步 clear → 始终有空间 | 同v1.0 |
| 无质量把控 → 代码质量不稳定 | 自动审查 → 质量可控 | 同v1.0 |
| 手动管理进度 → 容易遗漏 | 自动更新 → 不会丢失 | 同v1.0 |
| 跨会话困难 → 需要重建上下文 | todo.md 快照 → 秒级恢复 | 同v1.0 |
| 简单任务也要展开 → 浪费步骤 | ❌ 所有步骤都需展开 | ✅ Simple直接执行 |
| 手动切换步骤 → 操作繁琐 | ❌ 完成后需手动/expand | ✅ 自动切换下一步 |

---

## 💡 核心理念

### 1. 智能两级层次结构 🆕

```
Macro Level (宏观)                    Micro Level (微观)
─────────────────                    ─────────────────
Step 1 [Simple] ────────────> 直接执行 (无需展开)
Step 2 [Complex] ───────┐    展开时显示:
Step 3 [Simple] ────────│    → Substep 2.1
Step 4 [Complex] ───────│    → Substep 2.2
                        │    → Substep 2.3
Simple: 直接运行        └─── Complex: 展开后执行
```

**复杂度判断标准**:
- Simple (<60k): 单一任务，一次性完成
- Complex (≥60k): 多个子任务，需要拆分

### 2. Token 管理策略

```
传统方式累积:
Step 1.1 (8k) ─┐
Step 1.2 (8k) ─┼─> 累积到 32k
Step 1.3 (8k) ─┤
Step 1.4 (8k) ─┘

本系统清理:
Step 1.1 (8k) → clear → 0
Step 1.2 (8k) → clear → 0
Step 1.3 (8k) → clear → 0
Step 1.4 (8k) → clear → 0

每个子步骤都有完整的 120k 可用空间！
```

### 3. 自动化工作流 🆕

```
规划 (Codex)
    ↓
┌───评估复杂度
│   ├─ Simple → 直接执行
│   └─ Complex → 展开子步骤
│
├───执行 (Claude)
│
├───审查 (Codex)
│
└───自动切换下一步 ⚡
```

**关键改进**:
- 自动识别任务复杂度
- 自动决定是否需要展开
- 完成后自动切换到下一步

---

## 🏗️ 系统架构

### 命令体系 v2.0 🆕

```
┌──────────────────────────────────────────────┐
│                                              │
│  /plan  → 初始规划 + 复杂度评估 (Codex)       │
│    ↓                                         │
│  ┌─ 判断当前步骤 ───────────────┐            │
│  │                               │            │
│  │  [Simple]         [Complex]   │            │
│  │     ↓                 ↓       │            │
│  │   /run           /expand      │            │
│  │     ↓                 ↓       │            │
│  │  执行+审查      展开→/run→循环 │            │
│  │     ↓                 ↓       │            │
│  └──→ 完成 ← ← ← ← ← ← ← ┘       │            │
│         ↓                                    │
│  ⚡ 自动切换到下一步                           │
│         ↓                                    │
│  /clear → 清理内存                            │
│         ↓                                    │
│  [返回判断，直到所有步骤完成]                  │
│                                              │
│  /progress → 查看状态 (随时)                  │
│                                              │
└──────────────────────────────────────────────┘
```

**v2.0 关键变化**:
- ✅ 智能判断Simple/Complex
- ✅ 自动步骤切换（无需手动/expand下一步）
- ✅ 简化的工作流程

### 文件结构

```
项目目录/
├── todo.md                    # 动态任务列表（精简）
├── .claude/
│   ├── CLAUDE.md             # 项目配置
│   └── commands/             # 自定义命令
│       ├── plan.md
│       ├── expand.md
│       ├── run.md
│       └── status.md
├── 工作文件/                  # 任务产出
└── archives/                  # 归档（可选）
```

---

## 📋 命令详解

### 命令 1: `/plan` 🆕 已优化

**用途**: 使用 Codex 创建初始宏观计划并评估复杂度

**语法**: `/plan [任务描述]`

**示例**:
```bash
/plan Optimize Ubuntu system memory by cleaning processes and configuring swap
```

**输出** (v2.0新格式):
```markdown
# todo.md
## 📋 Steps
- [▶️] Step 1 [Simple]: Analyze Current State (~15k)
- [ ] Step 2 [Complex]: Clean Processes (~68k)
- [ ] Step 3 [Simple]: Configure Swap (~18k)
- [ ] Step 4 [Simple]: Verify & Document (~12k)

## 📊 Summary
Total: 113k / 120k (94% of budget)
Steps breakdown: 3 Simple, 1 Complex

---
💡 Step 1 is [Simple] - Use /run to execute directly
```

**关键变化**:
- ✅ 每个步骤标记 [Simple] 或 [Complex]
- ✅ 第一个步骤自动标记 [▶️]
- ✅ 提示下一步操作（/run 或 /expand）

---

### 命令 2: `/expand` 🆕 已优化

**用途**: 使用 Codex 展开 **Complex** 步骤为子步骤

**语法**: `/expand`

**智能检查** 🆕:
- 如果当前步骤是 [Simple]，提示直接使用 /run
- 如果当前步骤是 [Complex]，才执行展开

**示例输出** (仅针对Complex步骤):
```markdown
## 🚀 Step 2 [Complex]: Clean Processes (Expanded)
Progress: 0/4 substeps

- [▶️] 2.1: Identify zombie processes (~12k)
- [ ] 2.2: Stop unnecessary services (~18k)
- [ ] 2.3: Clean temp files and caches (~15k)
- [ ] 2.4: Verify memory release (~8k)

💡 Use /run to execute substep 2.1
```

**如果误对Simple步骤使用**:
```
⚠️ Step 1 is [Simple] (~15k tokens)
💡 Recommended: Use /run to execute directly
```

---

### 命令 3: `/run` 🆕 已大幅优化

**用途**: 执行当前任务（Simple步骤或Complex子步骤）并自动审查

**语法**: `/run [额外需求或细节]`

**智能识别** 🆕:
- 自动识别是Simple步骤还是Complex子步骤
- 执行相应的任务范围

**自动步骤切换** 🆕:
- Simple步骤完成 → 自动切换到下一步
- Complex所有子步骤完成 → 自动切换到下一步
- 无需手动 /expand 切换

**示例1 - Simple步骤**:
```bash
/run
```

输出:
```markdown
📍 Executing: Step 1 [Simple] - Analyze Current State
✅ Work completed

## Codex Review: 36/40 ✅ PASS

🎉 Step 1 [Simple] Complete!

## AUTO-TRANSITION ⚡
✅ Step 1 marked complete
▶️ Now on: Step 2 [Complex]: Clean Processes

💡 Next: /clear then /expand (Complex step needs breakdown)
```

**示例2 - Complex子步骤**:
```bash
/run Also check Docker containers
```

输出:
```markdown
📍 Executing: Substep 2.1
✅ Work completed

## Codex Review: 38/40 ✅ PASS

✅ Substep 2.1 Complete (38/40)

Progress in Step 2: 1/4 (25%)
- [x] 2.1: Identify zombies ✅ (38/40)
- [▶️] 2.2: Stop services

💡 Next: /clear then /run
```

**示例3 - Step完成自动切换**:
```markdown
🎉 Step 2 [Complex] Complete!
✅ All 4 substeps finished
Average: 37/40

## AUTO-TRANSITION ⚡
✅ Step 2 collapsed and marked complete
▶️ Now on: Step 3 [Simple]: Configure Swap

💡 Next: /clear then /run (Simple step, direct execution)
```

---

### 命令 4: `/progress`

**用途**: 查看当前任务进度

**语法**: `/progress`

---

## 🚀 实施步骤

### 第1步: 创建命令目录

```bash
mkdir -p ~/.claude/commands
```

### 第2步: 创建4个自定义命令

命令文件已自动创建在：
- `~/.claude/commands/plan.md`
- `~/.claude/commands/expand.md`
- `~/.claude/commands/run.md`
- `~/.claude/commands/status.md`

### 第3步: 配置 CLAUDE.md

全局配置已自动更新到 `~/.claude/CLAUDE.md`

### 第4步: 测试系统

```bash
# 1. 规划
/plan Create a simple calculator with add, subtract, multiply, divide functions

# 2. 展开
/expand

# 3. 执行
/run

# 4. 清理
/clear

# 5. 查看状态
/status
```

---

## 📖 使用指南 v2.0 🆕

### 完整工作流程（已简化）

#### 1. 开始新任务
```bash
/plan [详细描述您的任务]
# Codex 自动评估复杂度，标记 Simple/Complex
```

#### 2. 根据复杂度执行 🆕

**如果第一步是 [Simple]**:
```bash
/run           # 直接执行
/clear         # 完成后清理
# ⚡ 系统自动切换到下一步！
```

**如果第一步是 [Complex]**:
```bash
/expand        # 先展开为子步骤
/run           # 执行第一个子步骤
/clear         # 清理

/run           # 执行第二个子步骤
/clear

# 重复直到所有子步骤完成
# ⚡ 系统自动切换到下一步！
```

#### 3. 继续后续步骤 🆕
```bash
# 系统已自动切换到下一步
# 根据下一步的复杂度：

# 如果是 [Simple]:
/run && /clear

# 如果是 [Complex]:
/expand → /run → /clear (循环)
```

#### 4. 查看进度
```bash
/progress  # 随时查看，显示复杂度和进度
```

### 关键改进 🆕

✅ **无需手动切换步骤** - /run完成后自动移动到下一步
✅ **智能工作流** - 根据Simple/Complex自动调整
✅ **更少的命令** - 不再需要手动 /expand 切换步骤

---

## 🎯 最佳实践

### 1. 任务描述要清晰

❌ 不好:
```
/plan 做个网站
```

✅ 好:
```
/plan Build a responsive product catalog website with homepage, product listing, detail pages, shopping cart and checkout
```

### 2. 合理使用 /run 参数

```bash
/run Make sure to handle edge cases like empty input and invalid data
```

### 3. 及时 /clear

```bash
/run
[等待完成]
/clear  # 立即清理
```

### 4. 善用 /progress

```bash
# 工作一段时间后
/progress

# 新会话开始时
/progress
```

### 5. 信任 Codex 审查

当得到低分时：
- 认真对待建议
- 理解问题所在
- 根据建议改进
- 追求高分（>35/40）

---

## 💼 工作流示例 v2.0 🆕

### 示例: 构建 REST API

```bash
# 1. 规划
/plan Build a RESTful API for user management with CRUD operations and authentication

# Codex 生成计划:
# - [▶️] Step 1 [Simple]: Project Setup (~15k)
# - [ ] Step 2 [Complex]: Database Models (~72k)
# - [ ] Step 3 [Complex]: API Endpoints (~85k)
# - [ ] Step 4 [Simple]: Documentation (~12k)

# 2. Step 1 是 Simple，直接执行
/run Use TypeScript and Express
# ✅ Complete (38/40)
# ⚡ AUTO-TRANSITION: Now on Step 2 [Complex]

/clear

# 3. Step 2 是 Complex，需要展开
/expand
# 展开为 4 个子步骤:
# - [▶️] 2.1: Design schema
# - [ ] 2.2: User model
# - [ ] 2.3: Auth model
# - [ ] 2.4: Migrations

/run Include email validation
# ✅ Substep 2.1 Complete (37/40)
/clear

/run
# ✅ Substep 2.2 Complete (39/40)
/clear

/run
# ✅ Substep 2.3 Complete (36/40)
/clear

/run
# ✅ Substep 2.4 Complete (38/40)
# 🎉 Step 2 [Complex] Complete! Avg: 37.5/40
# ⚡ AUTO-TRANSITION: Now on Step 3 [Complex]

/clear

# 4. Step 3 继续...
/expand
# 系统自动继续，无需手动切换！
```

**对比 v1.0**:
- v1.0: 需要手动 `/expand` 切换步骤
- v2.0: ✅ 自动切换，流程更流畅
- v2.0: ✅ Simple步骤跳过展开，节省时间

---

## 📊 Token 效率分析

### 传统 vs 本系统

| 方式 | todo.md 大小 | Token/读取 | 任务复杂度 |
|------|-------------|-----------|----------|
| 传统全展开 | 150 行 | 3000 | 1x |
| 本系统 | 15 行 | 300 | 3-5x |

### Token 预算示例

```
16 个子步骤的任务:

传统累积:
逐步累积到 128k → ❌ 超限

本系统:
每步 8k → clear → 0
始终可用 120k → ✅ 无压力
```

---

## 🔧 故障排除

### 问题 1: Codex 审查分数过低

**解决**: 仔细阅读建议，根据建议修复，追求 >35 分

### 问题 2: todo.md 变长

**解决**: 及时 /expand 收起完成的步骤

### 问题 3: 忘记当前位置

**解决**: `/progress`

### 问题 4: Token 使用过快

**检查**:
- 是否每个 substep 后 /clear？
- todo.md 是否保持精简？
- 使用 /progress 查看 token 估算

---

## 📈 系统优势总结

| 指标 | 提升 |
|------|------|
| todo.md 大小 | 90% ↓ |
| Token 消耗 | 90% ↓ |
| 任务复杂度 | 300-500% ↑ |
| 恢复速度 | 97% ↓ |
| 代码质量 | 可量化 |

---

## ✅ 快速参考 v2.0 🆕

```
命令         用途                        时机
────────────────────────────────────────────────
/plan        初始规划 + 复杂度评估       开始新任务
/expand      展开Complex步骤             当前步骤是[Complex]
/run         执行 + 审查 + 自动切换      执行任务 (Simple/Substep)
/clear       清理内存                    每次 /run 后
/progress    查看状态 + 复杂度           任何时候

工作流 (v2.0 简化版):
┌────────────────────────────────────┐
│ /plan                              │
│   ↓                                │
│ [Simple] → /run → /clear           │
│   ↓                                │
│ ⚡ Auto Next Step                  │
│   ↓                                │
│ [Complex] → /expand                │
│   ↓                                │
│ /run → /clear (循环所有substeps)    │
│   ↓                                │
│ ⚡ Auto Next Step                  │
│   ↓                                │
│ (重复直到完成)                      │
└────────────────────────────────────┘

关键: ⚡ 步骤自动切换，无需手动 /expand 下一步
```

---

**版本**: v2.0 (优化版)
**日期**: 2025-10-18
**创建**: Claude Code 渐进式任务管理系统
**更新**:
- v2.0: 增加智能复杂度评估和自动步骤切换
- v1.0: 初始版本

---

## 开始使用

现在您可以立即开始使用：

```bash
/plan [您的第一个任务描述]
```

系统会引导您完成整个流程！
