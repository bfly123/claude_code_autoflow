---
description: Show current task progress and status
---

Display progress report.

## Step 1: Read todo.md

Parse ./todo.md to extract:
- Current expanded step
- All substeps with completion status
- Remaining steps
- Completed steps with scores

## Step 2: Display Report

**If Simple step** (not expanded):
```
📊 Progress Report

## Current
Step N [Simple]: [Title]
├─ Type: Direct execution
├─ Est: ~XYk tokens
└─ Status: [▶️] Ready

## Overall
├─ Steps: X/Y complete (Z%)
├─ Breakdown: A Simple, B Complex
├─ Tokens: ~XXk / 120k used
└─ Quality Avg: XX/40

💡 /run - Execute current step
```

**If Complex step** (expanded):
```
📊 Progress Report

## Current Step
Step N [Complex]: [Title]
├─ Progress: X/M substeps (Z%)
├─ Current: [▶️] N.M [desc]
└─ Avg Score: XX/40

## Substeps
- [x] N.1: ✅ (35/40)
- [x] N.2: ✅ (38/40)
- [▶️] N.3: ← YOU ARE HERE
- [ ] N.4: ...

## Overall
├─ Steps: X/Y complete
├─ Substeps: A/B done
├─ Tokens: ~XXk / 120k
└─ Overall Avg: XX/40

💡 /run - Execute N.M
```

## Error Handling

**If no todo.md**:
```
❌ No todo.md found
💡 Use /plan [task] to start
```
