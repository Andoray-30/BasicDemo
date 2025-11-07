# ============================================
#  Environment Manager - Unified Module
# ============================================
# 提供 user.mk 解析、环境变量加载、.env 生成等核心功能
# 其他脚本通过导入此模块复用功能

<#
.SYNOPSIS
    从 user.mk 解析所有变量并返回哈希表

.PARAMETER UserMkPath
    user.mk 文件路径，默认为当前目录下的 user.mk

.OUTPUTS
    返回包含所有变量的哈希表，已展开变量引用
#>
function Parse-UserMk {
    Param([string]$UserMkPath = "user.mk")
    
    if (-not (Test-Path $UserMkPath)) {
        Write-Warning "user.mk not found at: $UserMkPath"
        return @{}
    }
    
    $env_dict = @{}
    
    # 第一遍：读取所有变量
    Get-Content $UserMkPath | ForEach-Object {
        $line = $_.Trim()
        # 跳过注释和空行
        if ($line -match '^[#;]' -or $line -eq '') { return }
        # 匹配 KEY=VALUE 格式
        if ($line -match '^([A-Za-z0-9_]+)\s*=\s*(.+)$') {
            $key = $matches[1]
            $val = $matches[2].Trim()
            # 去掉可选的引号
            if ($val -match '^"(.*)"$') { $val = $matches[1] }
            $env_dict[$key] = $val
        }
    }
    
    # 第二遍：展开变量引用 $(VAR_NAME)
    $maxIterations = 10  # 防止循环引用
    $changed = $true
    $iteration = 0
    
    while ($changed -and $iteration -lt $maxIterations) {
        $changed = $false
        $iteration++
        
        foreach ($key in @($env_dict.Keys)) {
            $val = $env_dict[$key]
            $originalVal = $val
            
            # 展开所有 $(VAR_NAME) 引用
            while ($val -match '\$\(([A-Za-z0-9_]+)\)') {
                $varName = $matches[1]
                if ($env_dict.ContainsKey($varName)) {
                    $val = $val -replace "\`$\($varName\)", $env_dict[$varName]
                } else {
                    # 无法解析的变量，跳过
                    break
                }
            }
            
            if ($val -ne $originalVal) {
                $env_dict[$key] = $val
                $changed = $true
            }
        }
    }
    
    return $env_dict
}

<#
.SYNOPSIS
    将 user.mk 变量加载到当前 PowerShell 环境

.PARAMETER UserMkPath
    user.mk 文件路径

.PARAMETER AddToPath
    是否将工具路径添加到 PATH 环境变量
#>
function Import-UserEnv {
    Param(
        [string]$UserMkPath = "user.mk",
        [bool]$AddToPath = $true
    )
    
    $env_dict = Parse-UserMk -UserMkPath $UserMkPath
    
    if ($env_dict.Count -eq 0) {
        return
    }
    
    $paths_to_add = @()
    
    foreach ($key in $env_dict.Keys) {
        $val = $env_dict[$key]
        
        # 把 / 转成 \ (Windows 路径)
        $val = $val -replace '/', '\\'
        
        # 设置环境变量
        Set-Item -Path "env:$key" -Value $val -ErrorAction SilentlyContinue
        
        # 收集工具路径
        if ($AddToPath) {
            if ($key -eq "GCC_PATH" -and $val -ne "") { 
                $paths_to_add += $val 
            }
            if ($key -eq "OPENOCD_PATH" -and $val -ne "") { 
                $paths_to_add += "$val\bin" 
            }
            if ($key -eq "SEGGER_JLINK_DIR" -and $val -ne "") { 
                $paths_to_add += $val 
            }
        }
    }
    
    # 添加到 PATH
    if ($AddToPath -and $paths_to_add.Count -gt 0) {
        $existing_path = [Environment]::GetEnvironmentVariable('PATH', 'Process')
        foreach ($path in $paths_to_add) {
            if ($existing_path -notlike "*$path*") {
                $existing_path = "$path;$existing_path"
            }
        }
        [Environment]::SetEnvironmentVariable('PATH', $existing_path, 'Process')
    }
}

<#
.SYNOPSIS
    从 user.mk 生成 .vscode/.env 文件

.PARAMETER UserMkPath
    user.mk 文件路径

.PARAMETER OutFile
    输出的 .env 文件路径
#>
function Export-VscodeEnv {
    Param(
        [string]$UserMkPath = "user.mk",
        [string]$OutFile = ".vscode/.env"
    )
    
    $env_dict = Parse-UserMk -UserMkPath $UserMkPath
    
    if ($env_dict.Count -eq 0) {
        Write-Warning "No variables found in $UserMkPath"
        return
    }
    
    # 确保 .vscode 目录存在
    $outDir = Split-Path -Parent $OutFile
    if ($outDir -and -not (Test-Path $outDir)) { 
        New-Item -Path $outDir -ItemType Directory | Out-Null 
    }
    
    # 生成 .env 内容
    $lines = @(
        "# Auto-generated from $UserMkPath by env-manager.ps1"
        "# Do not edit manually - changes will be overwritten"
        ""
    )
    
    foreach ($key in ($env_dict.Keys | Sort-Object)) {
        $val = $env_dict[$key]
        # 把 / 转成 \ (Windows 路径)
        $val = $val -replace '/', '\\'
        $lines += "$key=$val"
    }
    
    Set-Content -Path $OutFile -Value $lines -Encoding UTF8
    Write-Host "Generated $OutFile" -ForegroundColor Green
}

<#
.SYNOPSIS
    检查工具是否可用

.PARAMETER CommandName
    命令名称（如 'arm-none-eabi-gcc'）

.PARAMETER CheckPath
    可选的完整路径检查
#>
function Test-Tool {
    Param(
        [string]$CommandName,
        [string]$CheckPath = $null
    )
    
    # 优先检查指定路径
    if ($CheckPath -and (Test-Path $CheckPath)) {
        return $true
    }
    
    # 检查是否在 PATH 中
    $cmd = Get-Command $CommandName -ErrorAction SilentlyContinue
    return $null -ne $cmd
}

# 注意：此文件通过 dot-sourcing (.) 加载，不是正式的 PowerShell 模块
# 函数会自动在调用脚本的作用域中可用
