# 从 user.mk 生成 .vscode/.env 文件
# 用法: .\scripts\generate-vscode-env.ps1

Param(
    [string]$UserMk = "user.mk",
    [string]$OutFile = ".vscode/.env"
)

# 导入环境管理模块
$modulePath = Join-Path $PSScriptRoot "env-manager.ps1"
if (Test-Path $modulePath) {
    . $modulePath
} else {
    Write-Error "env-manager.ps1 not found at: $modulePath"
    return
}

if (-not (Test-Path $UserMk)) {
    Write-Host "user.mk not found." -ForegroundColor Yellow
    return
}

# 使用统一模块生成 .env 文件
Export-VscodeEnv -UserMkPath $UserMk -OutFile $OutFile
