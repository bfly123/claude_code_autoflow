# Dual Design

Parallel independent design by Claude and Codex, then merge discussion.

**Usage**: Called internally by `/tp` and `/tr`, or directly for standalone design tasks.

---

## Input Parameters

From `$ARGUMENTS`:
- `design_type`: "plan" (for /tp) or "step" (for /tr)
- `requirement`: What needs to be designed
- `context`: Project/step context

---

## Execution Flow

### 1. Claude Independent Design

Design YOUR approach (do not show to Codex yet):

**For plan (design_type = "plan")**:
- Goal (1 sentence)
- Non-goals
- Steps (3-7 titles)
- Acceptance criteria (max 3)

**For step (design_type = "step")**:
- Implementation approach
- Done conditions (max 2)
- Potential risks
- Step atomicity:
  - needsSplit: true|false
  - splitReason: why split is required (if any)
  - proposedSubsteps: 3-7 titles (if needsSplit=true)

Save as `claude_design` internally.

### 2. Codex Independent Design

```
Bash(cask "Design independently for this requirement:

Type: [plan/step]
Requirement: [requirement]
Context: [context]

Provide:
[If plan]: Goal, Non-goals, Steps (3-7 titles), Acceptance (max 3)
[If step]: Implementation approach, Done conditions (max 2), Risks, Atomicity assessment (needsSplit/splitReason/proposedSubsteps)

Be specific. Do not ask for clarification.", run_in_background=true)
```

Wait with `TaskOutput`. Save as `codex_design`.

### 3. Merge Discussion

**Round 1 - Compare & Identify Differences**:

```
Bash(cask "Compare two designs:

DESIGN A (Claude):
[claude_design]

DESIGN B (Codex):
[codex_design]

Analyze:
1. Overlapping/redundant parts
2. Unique contributions from each
3. Conflicts or contradictions
4. Missing elements in both
5. Step atomicity: should this step be split into substeps?

Recommend: Which parts to keep from each?", run_in_background=true)
```

**Round 2 - Resolve & Merge**:

Based on Round 1, propose merged design:

```
Bash(cask "Proposed merged design:

[merged_design]

Remaining issues:
- [issue 1]
- [issue 2]

Your recommendations?", run_in_background=true)
```

**Round 3 (if needed)** - Final check if major disagreements exist.

### 4. Output

Return merged design:

**For plan**:
```
goal: [merged goal]
nonGoals: [merged non-goals]
steps: [merged steps]
acceptance: [merged criteria]
```

**For step**:
```
approach: [merged approach]
doneConditions: [merged conditions]
risks: [merged risks]
needsSplit: true|false
splitReason: [if needsSplit=true]
proposedSubsteps:
- [S?.1 title]
- [S?.2 title]
```

---

## Principles

1. **True Independence**: Neither sees the other's design first
2. **Structured Merge**: Compare → Resolve → Finalize
3. **Max 3 Rounds**: Avoid endless discussion
4. **Concrete Output**: Return usable design, not discussion notes
5. **Plan Mode Only**: No mode switching; no file edits in this skill
