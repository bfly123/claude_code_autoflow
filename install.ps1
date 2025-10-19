# Claude Code Progressive Task System - PowerShell Installer
# Version: 3.0

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Claude Code Progressive Task System" -ForegroundColor Cyan
Write-Host "PowerShell Installation Script v3.0" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check execution policy
$executionPolicy = Get-ExecutionPolicy
if ($executionPolicy -eq "Restricted") {
    Write-Host "[WARNING] PowerShell execution policy is Restricted" -ForegroundColor Yellow
    Write-Host "Run: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Yellow
    Write-Host ""
}

# Define paths
$claudeDir = Join-Path $env:USERPROFILE ".claude"
$commandsDir = Join-Path $claudeDir "commands"

# Check/Create Claude Code directory
if (-not (Test-Path $claudeDir)) {
    Write-Host "[INFO] Creating Claude Code directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
    New-Item -ItemType Directory -Path $commandsDir -Force | Out-Null
    Write-Host "[OK] Created: $claudeDir" -ForegroundColor Green
} else {
    Write-Host "[OK] Found: $claudeDir" -ForegroundColor Green
    if (-not (Test-Path $commandsDir)) {
        New-Item -ItemType Directory -Path $commandsDir -Force | Out-Null
    }
}

# Check if running from project root
if (-not (Test-Path "commands\plan.md")) {
    Write-Host "[ERROR] Command files not found" -ForegroundColor Red
    Write-Host "Please run this script from the project root directory" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Install command files
Write-Host ""
Write-Host "Installing command files..." -ForegroundColor Cyan

$commands = @(
    @{File="plan.md"; Name="/plan"},
    @{File="run.md"; Name="/run"},
    @{File="progress.md"; Name="/progress"},
    @{File="expand.md"; Name="/expand (deprecated)"}
)

foreach ($cmd in $commands) {
    $source = Join-Path "commands" $cmd.File
    $dest = Join-Path $commandsDir $cmd.File

    if (Test-Path $source) {
        Copy-Item $source $dest -Force
        Write-Host "[OK] Installed: $($cmd.Name)" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Not found: $source" -ForegroundColor Red
    }
}

# Optional: Install global CLAUDE.md
Write-Host ""
$installConfig = Read-Host "Install global CLAUDE.md configuration? (Y/N)"

if ($installConfig -eq "Y" -or $installConfig -eq "y") {
    $examplePath = "CLAUDE.md.example"
    $destPath = Join-Path $claudeDir "CLAUDE.md"

    if (Test-Path $examplePath) {
        if (Test-Path $destPath) {
            Write-Host "[WARNING] CLAUDE.md already exists" -ForegroundColor Yellow
            $overwrite = Read-Host "Overwrite? (Y/N)"
            if ($overwrite -eq "Y" -or $overwrite -eq "y") {
                Copy-Item $examplePath $destPath -Force
                Write-Host "[OK] Installed global configuration" -ForegroundColor Green
            } else {
                Write-Host "[SKIP] Kept existing configuration" -ForegroundColor Yellow
            }
        } else {
            Copy-Item $examplePath $destPath -Force
            Write-Host "[OK] Installed global configuration" -ForegroundColor Green
        }
    } else {
        Write-Host "[WARNING] CLAUDE.md.example not found" -ForegroundColor Yellow
    }
} else {
    Write-Host "[SKIP] Global configuration not installed" -ForegroundColor Yellow
}

# Verify installation
Write-Host ""
Write-Host "Verifying installation..." -ForegroundColor Cyan

$allInstalled = $true
foreach ($cmd in $commands) {
    $path = Join-Path $commandsDir $cmd.File
    if (-not (Test-Path $path)) {
        Write-Host "[ERROR] Missing: $($cmd.File)" -ForegroundColor Red
        $allInstalled = $false
    }
}

if ($allInstalled) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "[SUCCESS] Installation complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Available commands:" -ForegroundColor Cyan
    Write-Host "  /plan [task]       - Create plan"
    Write-Host "  /run [details]     - Execute with auto-expand"
    Write-Host "  /progress          - Show progress"
    Write-Host ""
    Write-Host "Quick start:" -ForegroundColor Cyan
    Write-Host "  1. Open Claude Code"
    Write-Host "  2. Run: /plan [your task]"
    Write-Host "  3. Run: /run"
    Write-Host "  4. Run: /clear"
    Write-Host "  5. Repeat steps 3-4"
    Write-Host ""
    Write-Host "Documentation:" -ForegroundColor Cyan
    Write-Host "  - README.md        - English guide"
    Write-Host "  - README.md#中文文档-chinese-documentation  - Chinese guide"
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "[ERROR] Installation incomplete" -ForegroundColor Red
    Write-Host "Please check error messages above" -ForegroundColor Red
}

Read-Host "Press Enter to exit"
