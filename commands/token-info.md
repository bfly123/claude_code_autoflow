---
description: Show detailed token usage analysis and optimization tips
---

Display comprehensive token usage information:

## Step 1: Trigger Token Display

Execute a lightweight command to get current token usage from system:

```bash
pwd
```

## Step 2: Analyze and Display Report

Parse the token usage information and create detailed report:

```
📊 Token Usage Report
═══════════════════════════════════════════════

## Current Usage
```

From the system warning, extract:
- Total used tokens
- Total budget (200,000)
- Remaining tokens
- Usage percentage

Display as:
```
├─ Used:      XX,XXX tokens
├─ Available: 200,000 tokens
├─ Remaining: XX,XXX tokens
└─ Usage:     XX.X%

Progress: [▓▓▓▓▓▓▓░░░░░░░░░░░░] XX%
```

## Step 3: Context Breakdown Estimation

⚠️ **The Hidden Iceberg**: `/clear` wipes the chat log, not the base context Claude must carry. Think iceberg: the conversation is the visible tip; the persistent base is the hidden mass burning tokens.

Estimate and display context components:

```
## Context Breakdown (Estimated)

### 🧊 Persistent Base Context (~9-30k tokens) - The Hidden Iceberg

⚠️ **This burns tokens even after /clear**

#### System Scaffolding (~6-8k tokens)
├─ System Prompt:        ~5,000 tokens (Claude Code instructions)
├─ CLAUDE.md (global):   ~300-500 tokens (user's global config)
├─ Environment Info:     ~500 tokens (OS, paths, git status)
└─ Commands Index:       ~500-1,000 tokens (available slash commands)

#### 🚨 Project Analysis Iceberg (~3-22k tokens) - LARGEST OVERHEAD
**⚠️ Poorly maintained repos waste massive tokens here**

├─ Project Structure:    ~1,000-5,000 tokens
│   └─ Directory tree, file count, dependency graph
├─ Codebase Summary:     ~2,000-10,000 tokens  🚨 MAJOR WASTE
│   └─ Language detection, framework ID, architecture
│   └─ ❗ Bloated by: unused deps, build artifacts, sprawling configs
├─ Recent File Access:   ~500-3,000 tokens
│   └─ Recently read files, uncommitted changes
├─ Project Config:       ~500-2,000 tokens
│   └─ package.json, tsconfig, .env (if massive, costs more)
└─ Active Todos/Plans:   ~0-2,000 tokens

#### Session Continuity (~0-5k tokens)
└─ Session Summary:      ~2,000-5,000 tokens (if resumed)

**💡 Key Insight**: Messy, overgrown repos spike this hidden overhead and
waste tokens even after `/clear`. A poorly organized project can burn
20-30k tokens BEFORE you write a single line of code.

### Conversation History (~X tokens - CLEARED by /clear)
├─ User Messages:        ~X tokens
├─ Assistant Responses:  ~X tokens
├─ Tool Call Results:    ~X tokens
└─ File Reads:           ~X tokens

### Calculation
Total Used:       XX,XXX tokens
├─ Persistent Base: ~XX,XXX tokens 🧊 (ICEBERG - never cleared)
│   ├─ System:      ~X,XXX tokens
│   └─ Project:     ~X,XXX tokens 🚨 (waste if repo is messy)
└─ Conversation:    ~XX,XXX tokens (cleared by /clear)

**After /clear**: Usage drops to ~XX,XXX tokens (persistent base only)
**The iceberg remains**: Tight project hygiene keeps this burn manageable.
```

## Step 4: Usage Status & Recommendations

Based on current usage percentage, provide status and tips:

**If < 30% used (Green Zone):**
```
✅ Status: Excellent - Plenty of space available

💡 Tips:
- Continue working normally
- No optimization needed
- Can handle large file reads and complex operations
```

**If 30-60% used (Yellow Zone):**
```
⚠️ Status: Moderate - Consider optimization

💡 Tips:
- Use /clear periodically to free conversation history
- Avoid reading very large files repeatedly
- Use targeted file reads (specific line ranges)
- Consider breaking complex tasks into smaller steps
```

**If 60-80% used (Orange Zone):**
```
⚠️ Status: High Usage - Optimization recommended

💡 Tips:
- Use /clear NOW to free ~XX,XXX tokens
- Read only essential files
- Use grep/glob instead of full file reads
- Break tasks into smaller chunks
- Consider starting fresh session for new tasks
```

**If > 80% used (Red Zone):**
```
🚨 Status: Critical - Action required

💡 Urgent Actions:
1. Execute /clear immediately
2. Avoid large file reads
3. Use minimal context operations
4. Consider restarting session
5. Save important work before proceeding

⚠️ Risk: Approaching context limit
```

## Step 5: Capacity Estimate

Calculate and display remaining capacity:

```
## Remaining Capacity

Based on current usage, estimated capacity for:

├─ Small operations (grep/glob):     ~XXX operations
├─ Medium file reads (<1k lines):    ~XX operations
├─ Large file reads (1-5k lines):    ~X operations
├─ Complex tool chains:              ~X operations
└─ Substeps (from /run workflow):    ~X substeps

💡 Recommendation:
[Specific advice based on remaining capacity]
```

## Step 6: Optimization Suggestions

Provide specific optimization tips:

```
## Optimization Tips

### Understanding The Iceberg Problem

⚠️ **Why /clear doesn't free all tokens**:
The conversation is the tip of the iceberg. The hidden base—system
scaffolding + project analysis—sits in memory and burns tokens constantly.

**Iceberg breakdown**:
- System scaffolding (~6-8k): unavoidable overhead
- **Project analysis iceberg (~3-22k)**: 🚨 THE HIDDEN WASTE
  - Small, clean projects: ~3-5k tokens
  - Medium projects (poor hygiene): ~8-15k tokens
  - Large, sprawling repos: ~15-30k tokens 💸 MASSIVE WASTE

**Root cause of waste**: Bloated dependencies, uncommitted build artifacts,
massive config files, and poor repo hygiene spike the hidden overhead.

### To Minimize The Iceberg:
**Clean your project**:
- Use .claudeignore to exclude node_modules, build/, dist/, .cache/
- Keep package.json and config files lean (remove unused deps)
- Commit or gitignore build artifacts and temp files
- Work in smaller subdirectories when possible

**Manage sessions efficiently**:
- /clear removes conversation but NOT the iceberg
- Restart session only when necessary (re-analysis costs similar tokens)
- Use glob/grep over full file reads
- Batch operations before /clear

**For bloated projects (>20k base)**:
- Accept ~60-80k usable conversation space (not full 200k)
- Break work into focused feature-branch sessions
- Prioritize repo cleanup to reclaim wasted tokens
- Monitor /token-info to track the burn

### Best Practices:
- Treat base context as a tax on messy repos
- **Tight project hygiene = lower token waste**
- Monitor usage with /token-info regularly
- Plan for ~15-25k iceberg in real projects (less with cleanup)
```

## Step 7: Quick Reference

```
## Quick Actions

/clear          - Free conversation history (~X tokens)
/token-info     - Run this analysis again
/progress       - Check task progress (from PLAN.md system)

## Token Costs (Approximate)
- Small file read (<100 lines):    ~200 tokens
- Medium file read (<1k lines):    ~2,000 tokens
- Large file read (5k lines):      ~10,000 tokens
- Tool call + result:              ~500-2,000 tokens
- User message + response:         ~1,000-3,000 tokens
```

---

**Note:** Token estimates are approximate. Actual usage may vary based on content complexity and formatting.
