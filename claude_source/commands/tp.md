---
description: AutoFlow Plan - Create task plan with dual design
argument-hint: <requirement>
allowed-tools: Read, Glob, Grep, Bash, Task, Skill, WebSearch, WebFetch, AskUserQuestion
---

Execute the AutoFlow Plan workflow.

Read and follow:
- `~/.claude/skills/tp/SKILL.md`
- `~/.claude/skills/tp/references/flow.md`

Input: `$ARGUMENTS` (the requirement to plan)

Do not modify files directly; delegate all file operations to Codex via `/file-op`.
