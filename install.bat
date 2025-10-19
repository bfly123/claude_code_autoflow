@echo off
REM Claude Code Progressive Task System - Windows Installer
REM Version: 3.0

echo ========================================
echo Claude Code Progressive Task System
echo Windows Installation Script v3.0
echo ========================================
echo.

REM Check Claude Code directory
set CLAUDE_DIR=%USERPROFILE%\.claude

if not exist "%CLAUDE_DIR%" (
    echo [WARNING] Claude Code directory not found
    echo Creating %CLAUDE_DIR%...
    mkdir "%CLAUDE_DIR%"
    mkdir "%CLAUDE_DIR%\commands"
    echo [OK] Created Claude Code directory
) else (
    echo [OK] Found Claude Code directory: %CLAUDE_DIR%
)

REM Install command files
echo.
echo Installing command files...

if not exist "commands\plan.md" (
    echo [ERROR] commands\plan.md not found
    echo Please run this script from the project root directory
    pause
    exit /b 1
)

copy /Y "commands\plan.md" "%CLAUDE_DIR%\commands\" >nul
echo [OK] Installed: /plan

copy /Y "commands\run.md" "%CLAUDE_DIR%\commands\" >nul
echo [OK] Installed: /run

copy /Y "commands\progress.md" "%CLAUDE_DIR%\commands\" >nul
echo [OK] Installed: /progress

copy /Y "commands\expand.md" "%CLAUDE_DIR%\commands\" >nul
echo [OK] Installed: /expand (deprecated)

REM Optional: Install global CLAUDE.md
echo.
echo Install global CLAUDE.md configuration? (Y/N)
set /p INSTALL_CONFIG=
if /i "%INSTALL_CONFIG%"=="Y" (
    if exist "CLAUDE.md.example" (
        if exist "%CLAUDE_DIR%\CLAUDE.md" (
            echo [WARNING] CLAUDE.md already exists
            echo Overwrite? (Y/N)
            set /p OVERWRITE=
            if /i "%OVERWRITE%"=="Y" (
                copy /Y "CLAUDE.md.example" "%CLAUDE_DIR%\CLAUDE.md" >nul
                echo [OK] Installed global configuration
            ) else (
                echo [SKIP] Kept existing configuration
            )
        ) else (
            copy /Y "CLAUDE.md.example" "%CLAUDE_DIR%\CLAUDE.md" >nul
            echo [OK] Installed global configuration
        )
    ) else (
        echo [WARNING] CLAUDE.md.example not found
    )
) else (
    echo [SKIP] Global configuration not installed
)

REM Verify installation
echo.
echo Verifying installation...

set ALL_INSTALLED=1

if not exist "%CLAUDE_DIR%\commands\plan.md" (
    echo [ERROR] plan.md not installed
    set ALL_INSTALLED=0
)

if not exist "%CLAUDE_DIR%\commands\run.md" (
    echo [ERROR] run.md not installed
    set ALL_INSTALLED=0
)

if not exist "%CLAUDE_DIR%\commands\progress.md" (
    echo [ERROR] progress.md not installed
    set ALL_INSTALLED=0
)

if %ALL_INSTALLED%==1 (
    echo.
    echo ========================================
    echo [SUCCESS] Installation complete!
    echo ========================================
    echo.
    echo Available commands:
    echo   /plan [task]       - Create plan
    echo   /run [details]     - Execute with auto-expand
    echo   /progress          - Show progress
    echo.
    echo Quick start:
    echo   1. Open Claude Code
    echo   2. Run: /plan [your task]
    echo   3. Run: /run
    echo   4. Run: /clear
    echo   5. Repeat steps 3-4
    echo.
    echo Documentation:
    echo   - README.md        - English guide
    echo   - README.md#中文文档-chinese-documentation  - Chinese guide
    echo.
) else (
    echo.
    echo [ERROR] Installation incomplete
    echo Please check error messages above
)

echo.
pause
