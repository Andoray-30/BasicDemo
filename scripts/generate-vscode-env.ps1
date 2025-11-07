# 从 user.mk 生成 .vscode/.env 文件
# 用法: .\scripts\generate-vscode-env.ps1

Param(
    [string]$UserMk = "user.mk",
    [string]$OutFile = ".vscode/.env"
)

if (-not (Test-Path $UserMk)) {
    Write-Host "user.mk not found." -ForegroundColor Yellow
    return
}

if (-not (Test-Path ".vscode")) { New-Item -Path ".vscode" -ItemType Directory | Out-Null }

$lines = @()
Get-Content $UserMk | ForEach-Object {
    $line = $_.Trim()
    if ($line -match '^[#;]' -or $line -eq '') { return }
    if ($line -match '^([A-Za-z0-9_]+)\s*=\s*(.+)$') {
        $key = $matches[1]
        $val = $matches[2].Trim()
        if ($val -match '^"(.*)"$') { $val = $matches[1] }
        $val = $val -replace '/', '\\'
        $lines += "$key=$val"
    }
}

Set-Content -Path $OutFile -Value $lines -Encoding UTF8
Write-Host "Generated $OutFile" -ForegroundColor Green
