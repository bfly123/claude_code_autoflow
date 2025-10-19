# Project Structure

This document explains the organization of the Claude TriFlow project.

## Directory Tree

```
claude-triflow/
├── commands/              # Command definitions
│   ├── plan.md           # Planning command (85 lines)
│   ├── run.md            # Execution command (94 lines)
│   ├── progress.md       # Progress display (67 lines)
│   ├── expand.md         # Deprecated in v3.0 (14 lines)
│   └── token-info.md     # Token usage info (optional)
│
├── docs/                  # Additional documentation (empty for now)
│
├── Installation Scripts
│   ├── install.sh        # Linux/macOS installer
│   ├── install.bat       # Windows batch installer
│   └── install.ps1       # Windows PowerShell installer
│
├── Documentation
│   ├── README.md         # English main documentation
│   ├── README.md#中文文档-chinese-documentation   # Chinese documentation
│   ├── INSTALL.md        # Quick install guide
│   ├── PROJECT.md        # Project overview (this file's companion)
│   ├── STRUCTURE.md      # This file
│   ├── PLAN.md           # Design document (v3.0)
│   ├── CHANGELOG.md      # Version history
│   └── CONTRIBUTING.md   # Contribution guidelines
│
├── Configuration
│   ├── .gitignore        # Git ignore rules
│   └── CLAUDE.md.example # Optional global config template
│
└── LICENSE               # MIT License
```

## File Descriptions

### Commands (`commands/`)

**Core Commands**:
- `plan.md` - Creates initial task plan with Codex
- `run.md` - Executes tasks with auto-expand + review
- `progress.md` - Shows current progress

**Deprecated**:
- `expand.md` - Marked deprecated (functionality in run.md)

**Optional**:
- `token-info.md` - Token usage analysis

### Installation Scripts

All three scripts do the same thing:
1. Check for Claude Code directory
2. Copy command files
3. Optional: Install global config
4. Verify installation

**Platform-specific**:
- `install.sh` - Bash (Linux/macOS)
- `install.bat` - Batch (Windows, maximum compatibility)
- `install.ps1` - PowerShell (Windows, recommended)

### Documentation

**User-facing**:
- `README.md` - Primary docs (English)
- `README.md#中文文档-chinese-documentation` - Full Chinese version
- `INSTALL.md` - Quick install reference

**Developer/Contributor**:
- `PROJECT.md` - Project vision and goals
- `STRUCTURE.md` - This file
- `PLAN.md` - Technical design details
- `CONTRIBUTING.md` - How to contribute

**History**:
- `CHANGELOG.md` - Version changes

### Configuration

- `.gitignore` - Excludes temp files, logs, etc.
- `CLAUDE.md.example` - Template for global Claude Code config

## File Sizes

### Command Files (Total: 260 lines)
```
plan.md:     85 lines
run.md:      94 lines
progress.md: 67 lines
expand.md:   14 lines
```

**Optimization**: Reduced from 688 lines (62% smaller)

### Documentation (Total: ~50 KB)
```
README.md:        ~6 KB
README.md#中文文档-chinese-documentation:  ~16 KB
INSTALL.md:       ~3 KB
PLAN.md:          ~16 KB
CHANGELOG.md:     ~5 KB
CONTRIBUTING.md:  ~4 KB
```

## Installation Locations

When installed, files go to:

**Linux/macOS**: `~/.claude/commands/`
**Windows**: `%USERPROFILE%\.claude\commands\`

Installed files:
- plan.md
- run.md  
- progress.md
- expand.md

## Workflow Overview

```
User runs:           File used:
-----------          ----------
/plan [task]    →    commands/plan.md
/run            →    commands/run.md (auto-calls Codex if needed)
/progress       →    commands/progress.md
/clear          →    (built-in Claude Code command)
```

## Contributing to Structure

If you want to propose changes:

1. **Adding files**: Update this document
2. **Reorganizing**: Discuss in an issue first
3. **Removing files**: Ensure backward compatibility

---

Last updated: 2025-10-19 (v3.0)
