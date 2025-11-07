# 从 user.mk 加载环境变量到当前 PowerShell 会话
# 用法: . .\scripts\load-user-env.ps1

Param([string]$UserMk = "user.mk")

if (-not (Test-Path $UserMk)) {
    Write-Host "user.mk not found. Copy from user.mk.example first." -ForegroundColor Yellow
    return
}

# 解析所有变量
$env_dict = @{}
Get-Content $UserMk | ForEach-Object {
    $line = $_.Trim()
    if ($line -match '^[#;]' -or $line -eq '') { return }
    if ($line -match '^([A-Za-z0-9_]+)\s*=\s*(.+)$') {
        $key = $matches[1]
        $val = $matches[2].Trim()
        # 去掉可选的引号
        if ($val -match '^"(.*)"$') { $val = $matches[1] }
        $env_dict[$key] = $val
    }
}

# 设置环境变量
$paths_to_add = @()
foreach ($key in $env_dict.Keys) {
    $val = $env_dict[$key]
    
    # 展开 $(VAR_NAME) 形式的变量引用
    while ($val -match '\$\(([A-Za-z0-9_]+)\)') {
        $var_name = $matches[1]
        if ($env_dict.ContainsKey($var_name)) {
            $val = $val -replace "\`$\($var_name\)", $env_dict[$var_name]
        } else {
            break
        }
    }
    
    # 把 / 转成 \ 
    $val = $val -replace '/', '\\'
    
    # 设置环境变量
    Set-Item -Path "env:$key" -Value $val -ErrorAction SilentlyContinue
    
    # 收集工具路径
    if ($key -eq "GCC_PATH" -and $val -ne "") { $paths_to_add += $val }
    if ($key -eq "OPENOCD_PATH" -and $val -ne "") { $paths_to_add += "$val\bin" }
    if ($key -eq "SEGGER_JLINK_DIR" -and $val -ne "") { $paths_to_add += $val }
}

# 添加到 PATH
if ($paths_to_add.Count -gt 0) {
    $existing_path = [Environment]::GetEnvironmentVariable('PATH', 'Process')
    foreach ($path in $paths_to_add) {
        if ($existing_path -notlike "*$path*") {
            $existing_path = "$path;$existing_path"
        }
    }
    [Environment]::SetEnvironmentVariable('PATH', $existing_path, 'Process')
}
