# Installation Guide

Quick installation guide for all platforms.

## 🚀 Easiest Method (Recommended)

**If you're already in Claude Code:**

```bash
# Simply reference this README in Claude Code:
@README.md Please install Claude TriFlow automatically
```

Claude will automatically:
- Detect your platform (Linux/macOS/Windows)
- Copy all command files to the correct location
- Verify the installation
- Prompt you to restart Claude Code

**Then restart Claude Code and you're ready to go!**

---

## Platform-Specific Instructions

### 🐧 Linux

```bash
git clone https://github.com/yourusername/claude-triflow.git
cd claude-triflow
chmod +x install.sh
./install.sh
```

---

### 🍎 macOS

```bash
git clone https://github.com/yourusername/claude-triflow.git
cd claude-triflow
chmod +x install.sh
./install.sh
```

---

### 🪟 Windows

#### PowerShell (Recommended)

```powershell
git clone https://github.com/yourusername/claude-triflow.git
cd claude-triflow
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install.ps1
```

#### Command Prompt

```cmd
git clone https://github.com/yourusername/claude-triflow.git
cd claude-triflow
install.bat
```

---

## Manual Installation

If scripts fail, copy commands manually:

### Linux/macOS
```bash
cp commands/*.md ~/.claude/commands/
```

### Windows (PowerShell)
```powershell
Copy-Item commands\*.md $env:USERPROFILE\.claude\commands\
```

### Windows (CMD)
```cmd
copy commands\*.md %USERPROFILE%\.claude\commands\
```

---

## Verify Installation

Open Claude Code and check available commands:

```
/plan
/run
/progress
```

All three should appear in auto-complete.

---

## Troubleshooting

### Linux/macOS

**Permission denied**:
```bash
chmod +x install.sh
```

**Directory not found**:
```bash
mkdir -p ~/.claude/commands
```

### Windows

**PowerShell execution policy**:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Directory not found**:
```cmd
mkdir %USERPROFILE%\.claude\commands
```

### All Platforms

**Commands not showing**:
1. Restart Claude Code
2. Check files exist in `~/.claude/commands/` (Linux/Mac) or `%USERPROFILE%\.claude\commands\` (Windows)
3. Try manual installation

---

## File Structure

After installation, you should have:

```
~/.claude/commands/          (or %USERPROFILE%\.claude\commands\ on Windows)
├── plan.md                  (85 lines)
├── run.md                   (94 lines)
├── progress.md              (67 lines)
└── expand.md                (14 lines, deprecated)
```

---

## Optional: Global Configuration

Install CLAUDE.md for all projects:

### Linux/macOS
```bash
cp CLAUDE.md.example ~/.claude/CLAUDE.md
```

### Windows (PowerShell)
```powershell
Copy-Item CLAUDE.md.example $env:USERPROFILE\.claude\CLAUDE.md
```

### Windows (CMD)
```cmd
copy CLAUDE.md.example %USERPROFILE%\.claude\CLAUDE.md
```

---

## Next Steps

1. ✅ Installation complete
2. Open Claude Code
3. Run: `/plan [your task]`
4. Run: `/run`
5. Run: `/clear`
6. Repeat steps 4-5

See [README.md](README.md) or [README.md#中文文档-chinese-documentation](README.md#中文文档-chinese-documentation) for full documentation.
