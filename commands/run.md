---
description: Execute task with adaptive expansion and review
argument-hint: [optional details]
---

Execute current task with intelligent complexity reassessment and adaptive expansion.

## Phase 0: Locate Work Item

1. Read `./todo.md`, find [▶️] marker
2. Capture:
   - Tier (Trivial/Simple/Complex)
   - Title and estimated tokens
   - Notes, risks, dependencies
3. Understand user's $ARGUMENTS if provided

## Phase 1: Reassess Complexity

⚠️ **Critical**: Don't blindly follow the planned tier. Reassess based on actual work.

**Investigation**:
1. Inspect relevant files and modules
2. Check existing code patterns and architecture
3. Evaluate actual changes needed vs estimated
4. Consider new information discovered since planning

**Complexity Adjustment**:
- **Planned tier overestimated?**
  - Example: "Complex" step but only needs single file change
  - → Downgrade to Simple/Trivial, execute directly
  - → Log: "Reassessed as Simple based on actual scope"

- **Planned tier underestimated?**
  - Example: "Simple" but discovered multiple dependencies
  - → Escalate, consider pausing to re-plan
  - → Warn user: "Complexity higher than planned, recommend /plan refresh"

- **New unknowns emerged?**
  - → Pause, seek clarification before proceeding

**Decision Criteria**:
```
Trivial:  Single file, <50 lines, no integrations → Execute directly
Simple:   Single component, clear scope, <3 files → Execute directly
Complex:  Multiple components/modules/services → Consider expansion
```

## Phase 2: Decide Execution Mode

### For Trivial/Simple Steps:
**Execute directly without substeps**
- Keep scope lean and focused
- One clear deliverable
- Skip expansion overhead

### For Complex Steps:
**Evaluate if substeps are truly needed**:

❌ **DON'T expand if**:
- Work is sequential but straightforward
- Changes are tightly coupled
- Token estimate alone drove "Complex" label
- Can be completed in one focused effort

✅ **DO expand if**:
- Multiple distinct components/modules
- Different integration points
- Natural break points for /clear
- Genuinely multi-deliverable

**Expansion Rules** (when needed):
- Create **2-4 substeps only** (not more)
- Each substep = discrete, testable outcome
- Each substep = file-based deliverable
- Each substep < 8k tokens

**Expansion format**:
```markdown
## 🚀 Step N [Complex] (Auto-Expanded)
Reasoning: [Why substeps are necessary]

- [▶️] N.1: [Action] (~Xk) — [What it delivers]
- [ ] N.2: [Action] (~Xk) — [What it delivers]
- [ ] N.3: [Action] (~Xk) — [What it delivers]

Validation: [How to verify all substeps complete the step]
```

**Log expansion decision**:
```
🔄 Auto-expanding Step N [Complex]...
Reasoning: Identified 3 distinct components (auth, session, API)
Creating 3 substeps for isolated validation
```

## Phase 3: Execute

**For Trivial/Simple** (~20-60k scope):
- Implement complete functionality
- Write clean, tested code
- Create necessary files
- Follow CLAUDE.md preferences

**For Substeps** (~5-8k scope):
- Implement specific component
- Save outputs to files (file-based handoff)
- Clear validation criteria
- Minimal but complete

**Execution Guidelines**:
- Follow user's CLAUDE.md rules (clean code, minimal comments)
- Consider $ARGUMENTS for additional context
- Write tests where appropriate
- Document complex logic
- Use meaningful file/function names

## Phase 4: Codex Review

Auto-trigger review with 40-point scale:

```
Code Quality (0-10):   Readability, structure, best practices
Correctness (0-10):    Requirements met, edge cases, error handling
Performance (0-10):    Algorithm efficiency, resource usage
Completeness (0-10):   All requirements covered, outputs complete
```

**Scoring**:
- **Pass**: ≥28/40
- **Excellent**: ≥35/40
- **Needs work**: <28/40

**If score ≥28**:
- Mark task [x] in todo.md with score
- Proceed to Phase 5 (auto-transition)

**If score <28**:
- Show detailed issues
- Offer options:
  1. Fix now (recommended)
  2. Review suggestions and retry
  3. Proceed anyway (not recommended)
  4. Re-plan task

## Phase 5: Auto-Transition

Update todo.md based on completion:

**Trivial/Simple Step Complete**:
```
✅ Step N [Tier] Complete (XX/40)
⚡ AUTO-TRANSITION: Now on Step N+1 [Tier]
💡 Recommend: /clear then /run
```

**Substep Complete**:
```
✅ Substep N.M Complete (XX/40)
📍 Progress: M/Total substeps done
⚡ AUTO-TRANSITION: Now on Substep N.M+1
💡 Recommend: /clear then /run
```

**All Substeps Complete**:
```
🎉 Step N [Complex] Complete! All substeps done.
   Average score: XX/40
⚡ AUTO-TRANSITION: Now on Step N+1
💡 Recommend: /clear then /run
```

**For Trivial tasks with no more work**:
```
✅ Task Complete (XX/40)
🎉 All done! No further steps.
```

## Workflow Summary

```
┌─ Trivial Step ────────────────────────┐
│  Reassess → Execute → Review → Done   │
└───────────────────────────────────────┘

┌─ Simple Step ─────────────────────────┐
│  Reassess → Execute → Review → Next   │
└───────────────────────────────────────┘

┌─ Complex Step (no expansion needed) ──┐
│  Reassess → Execute → Review → Next   │
└───────────────────────────────────────┘

┌─ Complex Step (expansion needed) ─────┐
│  Reassess → Expand → Execute N.1 →    │
│  Review → N.2 → ... → All done → Next │
└───────────────────────────────────────┘
```

## Key Principles

**Adaptive Complexity**:
- Always reassess before executing
- Don't blindly follow planned tier
- Adjust based on actual work discovered
- Communicate tier changes to user

**Smart Expansion**:
- Only expand when genuinely multi-component
- Fewer, meaningful substeps beat many trivial ones
- Each substep should be independently testable
- Avoid expansion for sequential but simple work

**Quality Control**:
- Every execution gets reviewed
- Pass threshold enforced (≥28/40)
- File-based outputs for /clear resilience
- Clear validation criteria

**Context Management**:
- ONE task per /run invocation
- Auto-update todo.md after completion
- Always suggest /clear after task
- Maintain state through files, not memory

---

**Remember**: The goal is **adaptive execution**, not rigid process.
Tier labels guide decisions but don't dictate them.
Use judgment based on actual complexity discovered during execution.
