@echo off
chcp 65001 >nul 2>&1
cls
echo ========================================
echo   BasicDemo Environment Setup
echo ========================================
echo.

REM Create user.mk
if not exist "user.mk" (
    if exist "user.mk.example" (
        copy user.mk.example user.mk >nul 2>&1
        echo [OK] Created user.mk
    ) else (
        echo [WARN] user.mk.example not found
    )
) else (
    echo [OK] user.mk exists
)

REM Set PowerShell execution policy
echo.
echo Configuring PowerShell...
powershell -NoProfile -Command "try { Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -ErrorAction Stop; Write-Host '[OK] Execution policy set' -ForegroundColor Green } catch { Write-Host '[WARN] Failed to set policy (may need admin)' -ForegroundColor Yellow }" 2>nul

REM Check tools
echo.
echo Checking development tools...
powershell -NoProfile -ExecutionPolicy Bypass -File ".\scripts\check-env.ps1"

echo.
echo ========================================
echo Next steps:
echo   1. Edit user.mk to configure paths
echo   2. Press Ctrl+Shift+B in VS Code
echo ========================================
echo.
pause


