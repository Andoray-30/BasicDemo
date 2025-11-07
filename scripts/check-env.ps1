# 检查开发工具是否可用
# 用法: .\scripts\check-env.ps1

# 导入环境管理模块
$modulePath = Join-Path $PSScriptRoot "env-manager.ps1"
if (Test-Path $modulePath) {
    . $modulePath
} else {
    Write-Error "env-manager.ps1 not found"
    exit 1
}

# 加载 user.mk 配置
if (Test-Path "user.mk") {
    Import-UserEnv -UserMkPath "user.mk" -AddToPath $true
}

function Check-Tool($cmd, $checkPath = $null) {
    if (Test-Tool -CommandName $cmd -CheckPath $checkPath) {
        Write-Host "[OK]     $cmd" -ForegroundColor Green
        return $true
    }
    
    Write-Host "[MISSING] $cmd" -ForegroundColor Yellow
    return $false
}

Write-Host "`nChecking development tools..." -ForegroundColor Cyan

$allOk = $true
$allOk = (Check-Tool 'arm-none-eabi-gcc') -and $allOk
$allOk = (Check-Tool 'mingw32-make') -and $allOk
$allOk = (Check-Tool 'JLink' $env:JLINK_EXE) -and $allOk
$allOk = (Check-Tool 'openocd') -and $allOk

if ($allOk) {
    Write-Host "`n[OK] All required tools found." -ForegroundColor Green
} else {
    Write-Host "`n[WARN] Some tools missing. Edit user.mk to configure paths." -ForegroundColor Yellow
}
