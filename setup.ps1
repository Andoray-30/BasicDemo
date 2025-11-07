# ============================================
#  BasicDemo 环境配置脚本 - 统一设置工具
# ============================================
# 使用方法: .\setup.ps1 [-SkipJLink] [-GenerateEnv]
#
# 参数说明:
#   -SkipJLink: 跳过 J-Link 工具的下载和安装
#   -GenerateEnv: 生成 VS Code 环境配置文件 (.vscode/.env)
#
# 主要功能:
#   1. 检查并创建 user.mk 配置文件（如果不存在）
#   2. 配置 PowerShell 脚本执行策略
#   3. 检查并验证开发工具环境
#   4. 可选：生成 VS Code 工作区环境配置文件
#   5. 可选：下载并安装 J-Link 调试工具

Param(
    [switch]$SkipJLink,
    [switch]$GenerateEnv
)

$ErrorActionPreference = 'Continue'

Write-Host ''
Write-Host '============================================' -ForegroundColor Cyan
Write-Host '  BasicDemo Environment Setup' -ForegroundColor Cyan
Write-Host '============================================' -ForegroundColor Cyan
Write-Host ''

# ===== 步骤 1: 检查并创建 user.mk 配置文件 =====
Write-Host '[1/5] 检查 user.mk 配置文件...' -ForegroundColor Yellow
if (-not (Test-Path 'user.mk')) {
    if (Test-Path 'user.mk.example') {
        Copy-Item 'user.mk.example' 'user.mk'
        Write-Host '  [成功] 已从示例文件创建 user.mk' -ForegroundColor Green
        Write-Host '  [提示] 请编辑 user.mk 文件配置工具链路径' -ForegroundColor Yellow
    } else {
        Write-Host '  [警告] 未找到 user.mk.example 示例文件' -ForegroundColor Red
    }
} else {
    Write-Host '  [成功] user.mk 配置文件已存在' -ForegroundColor Green
}

# ===== 步骤 2: 配置 PowerShell 脚本执行策略 =====
Write-Host ''
Write-Host '[2/5] 配置 PowerShell 脚本执行策略...' -ForegroundColor Yellow
try {
    $policy = Get-ExecutionPolicy -Scope CurrentUser
    if ($policy -eq 'Restricted' -or $policy -eq 'Undefined') {
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
        Write-Host '  [成功] 已将执行策略设置为 RemoteSigned' -ForegroundColor Green
    } else {
        Write-Host "  [成功] 当前执行策略: $policy" -ForegroundColor Green
    }
} catch {
    Write-Host '  [错误] 设置执行策略失败' -ForegroundColor Red
}

# ===== 步骤 3: 生成 VS Code 环境配置文件 (可选) =====
if ($GenerateEnv) {
    Write-Host ''
    Write-Host '[3/5] 生成 VS Code 环境配置文件...' -ForegroundColor Yellow
    if (Test-Path '.\scripts\generate-vscode-env.ps1') {
        & '.\scripts\generate-vscode-env.ps1'
    } else {
        Write-Host '  [警告] 未找到 generate-vscode-env.ps1 脚本' -ForegroundColor Red
    }
} else {
    Write-Host ''
    Write-Host '[3/5] 跳过环境配置文件生成 (使用 -GenerateEnv 参数启用)' -ForegroundColor Gray
}

# ===== 步骤 4: 下载并安装 J-Link 调试工具 (可选) =====
if (-not $SkipJLink) {
    Write-Host ''
    Write-Host '[4/5] 检查 J-Link 调试工具...' -ForegroundColor Yellow
    if (Test-Path '.\scripts\download-jlink.ps1') {
        Write-Host '  正在执行 J-Link 安装程序...' -ForegroundColor Gray
        & '.\scripts\download-jlink.ps1'
    } else {
        Write-Host '  [警告] 未找到 download-jlink.ps1 脚本' -ForegroundColor Red
    }
} else {
    Write-Host ''
    Write-Host '[4/5] 跳过 J-Link 工具安装 (移除 -SkipJLink 参数以启用)' -ForegroundColor Gray
}

# ===== 步骤 5: 检查开发工具环境 =====
Write-Host ''
Write-Host '[5/5] 检查开发工具环境...' -ForegroundColor Yellow
if (Test-Path '.\scripts\check-env.ps1') {
    & '.\scripts\check-env.ps1'
} else {
    Write-Host '  [错误] 未找到 check-env.ps1 脚本' -ForegroundColor Red
}

# ===== 环境配置完成 =====
Write-Host ''
Write-Host '============================================' -ForegroundColor Cyan
Write-Host '  环境配置完成!' -ForegroundColor Green
Write-Host '============================================' -ForegroundColor Cyan
Write-Host ''
Write-Host '后续操作步骤:' -ForegroundColor Cyan
Write-Host '  1. 编辑 user.mk 文件配置工具链路径' -ForegroundColor White
Write-Host '  2. 重启 VS Code 终端 (或执行: . .\scripts\load-user-env.ps1)' -ForegroundColor White
Write-Host '  3. 按 Ctrl+Shift+B 编译项目' -ForegroundColor White
Write-Host '  4. 按 F5 启动调试' -ForegroundColor White
Write-Host ''
