# 检查开发工具是否可用
# 用法: .\scripts\check-env.ps1

# 加载 user.mk 配置
if (Test-Path "user.mk") {
    . .\scripts\load-user-env.ps1
}

function Check-Tool($cmd, $checkPath = $null) {
    # 优先检查指定路径
    if ($checkPath -and (Test-Path $checkPath)) {
        Write-Host "[OK]     $cmd (found at $checkPath)" -ForegroundColor Green
        return $true
    }
    
    # 检查是否在 PATH 中
    $which = Get-Command $cmd -ErrorAction SilentlyContinue
    if ($which) {
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
