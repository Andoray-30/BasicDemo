# 从 user.mk 加载环境变量到当前 PowerShell 会话
# 用法: . .\scripts\load-user-env.ps1

Param([string]$UserMk = "user.mk")

# 导入环境管理模块
$modulePath = Join-Path $PSScriptRoot "env-manager.ps1"
if (Test-Path $modulePath) {
    . $modulePath
} else {
    Write-Error "env-manager.ps1 not found at: $modulePath"
    return
}

if (-not (Test-Path $UserMk)) {
    Write-Host "user.mk not found. Copy from user.mk.example first." -ForegroundColor Yellow
    return
}

# 使用统一模块加载环境
Import-UserEnv -UserMkPath $UserMk -AddToPath $true
