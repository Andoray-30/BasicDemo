# BasicDemo Environment Setup
# Usage: .\setup.ps1

Write-Host 'BasicDemo Environment Setup' -ForegroundColor Cyan
Write-Host ''

# Create user.mk
if (-not (Test-Path 'user.mk')) {
    if (Test-Path 'user.mk.example') {
        Copy-Item 'user.mk.example' 'user.mk'
        Write-Host '[OK] Created user.mk, please edit to configure paths' -ForegroundColor Green
    } else {
        Write-Host '[WARN] user.mk.example not found' -ForegroundColor Yellow
    }
} else {
    Write-Host '[OK] user.mk exists' -ForegroundColor Green
}

# Set execution policy
try {
    $policy = Get-ExecutionPolicy -Scope CurrentUser
    if ($policy -eq 'Restricted' -or $policy -eq 'Undefined') {
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
        Write-Host '[OK] PowerShell execution policy configured' -ForegroundColor Green
    } else {
        Write-Host '[OK] Execution policy already configured' -ForegroundColor Green
    }
} catch {
    Write-Host '[ERROR] Failed to set execution policy' -ForegroundColor Red
}

# Check tools
Write-Host ''
if (Test-Path '.\scripts\check-env.ps1') {
    & '.\scripts\check-env.ps1'
}

Write-Host ''
Write-Host 'Next steps:' -ForegroundColor Cyan
Write-Host '  1. Edit user.mk to configure toolchain paths' -ForegroundColor Gray
Write-Host '  2. Press Ctrl+Shift+B in VS Code to build' -ForegroundColor Gray
Write-Host '  3. Press F5 to debug' -ForegroundColor Gray
