<#
.SYNOPSIS
    Setup J-Link tools for portable project use.

.DESCRIPTION
    Copies required J-Link command-line executables from a system installation into
    the project's environment folder, enabling portable debugging without system-wide
    J-Link requirements.

    Strategy:
      1. Search for J-Link installation (system paths + env vars)
      2. Copy required executables to ./environment/jlink
      3. Verify copied files and display status
      4. If not found, guide user to download and install

    Required files:
      - JLink.exe           (J-Link Commander)
      - JLinkGDBServerCL.exe (GDB Server for debugging)
      - JlinkRTTClient.exe  (RTT logging client)
      - JLinkARM.dll        (J-Link core library - REQUIRED!)
      - JLink_x64.dll       (J-Link 64-bit library - REQUIRED!)
      
    Optional files (VC++ Runtime):
      - vcruntime140.dll, msvcp140.dll, etc. (copied if available)

.PARAMETER DestDir
    Target directory for J-Link tools (default: ./environment/jlink)

.PARAMETER Force
    Force recopy even if files already exist

.EXAMPLE
    .\scripts\download-jlink.ps1
    Standard setup - copy from system installation

.EXAMPLE
    .\scripts\download-jlink.ps1 -Force
    Recopy files even if they already exist

.NOTES
    ⚠️  LICENSING: J-Link software is proprietary (SEGGER Microcontroller GmbH).
        Do NOT redistribute J-Link binaries in public repositories.
        Each developer must have a valid J-Link license.
        
    This script copies from local installations only - it does not download
    binaries directly to comply with licensing terms.
#>

Param(
    [string]$DestDir = "./environment/jlink",
    [switch]$Force
)

$ErrorActionPreference = 'Continue'

# ============================================
#  Configuration
# ============================================

$REQUIRED_FILES = @(
    @{ Name = "JLink.exe";            Description = "J-Link Commander" }
    @{ Name = "JLinkGDBServerCL.exe"; Description = "GDB Server" }
    @{ Name = "JlinkRTTClient.exe";   Description = "RTT Client" }
    @{ Name = "JLinkARM.dll";         Description = "J-Link Core Library" }
    @{ Name = "JLink_x64.dll";        Description = "J-Link 64-bit Library" }
)

# VC++ Runtime DLLs (可选，如果系统没有则需要)
$OPTIONAL_RUNTIME_DLLS = @(
    "vcruntime140.dll",
    "msvcp140.dll",
    "concrt140.dll",
    "vccorlib140.dll",
    "vcruntime140_1.dll",
    "msvcp140_1.dll",
    "msvcp140_2.dll",
    "msvcp140_atomic_wait.dll"
)

$SEARCH_PATHS = @(
    '$env:SEGGER_JLINK_DIR',
    'C:\Program Files\SEGGER\JLink*',        # 支持版本号后缀 (如 JLink_V882j)
    'C:\Program Files (x86)\SEGGER\JLink*',
    'C:\SEGGER\JLink*',
    'D:\SEGGER\JLink*',
    'C:\Program Files\SEGGER\JLink',         # 兼容无版本号的旧安装
    'C:\Program Files (x86)\SEGGER\JLink'
)

$DOWNLOAD_URL = "https://www.segger.com/downloads/jlink/"

# ============================================
#  Helper Functions
# ============================================

function Write-StatusBox {
    Param([string]$Title, [string]$Color = "Cyan")
    $line = "=" * 50
    Write-Host ""
    Write-Host $line -ForegroundColor $Color
    Write-Host "  $Title" -ForegroundColor $Color
    Write-Host $line -ForegroundColor $Color
    Write-Host ""
}

function Find-JLinkInstallation {
    Write-Host "Searching for J-Link installation..." -ForegroundColor Cyan
    
    # 获取目标目录的绝对路径，避免搜索到自己
    $destDirAbs = $null
    if (Test-Path $DestDir) {
        $destDirAbs = (Resolve-Path $DestDir).Path
    }
    
    foreach ($pathPattern in $SEARCH_PATHS) {
        # 展开环境变量
        $expandedPath = $ExecutionContext.InvokeCommand.ExpandString($pathPattern)
        
        # 支持通配符路径（如 JLink*）
        if ($expandedPath -match '\*') {
            $matchedPaths = Get-Item $expandedPath -ErrorAction SilentlyContinue
            if ($matchedPaths) {
                # 如果有多个匹配，选择版本号最高的（按字母排序）
                $expandedPath = ($matchedPaths | Sort-Object Name -Descending | Select-Object -First 1).FullName
            } else {
                continue
            }
        }
        
        if (Test-Path $expandedPath) {
            # 避免检测到目标目录本身
            $currentPathAbs = (Resolve-Path $expandedPath).Path
            if ($destDirAbs -and ($currentPathAbs -eq $destDirAbs)) {
                continue
            }
            
            # 验证是否包含至少一个必需文件
            $hasAnyFile = $false
            foreach ($file in $REQUIRED_FILES) {
                if (Test-Path (Join-Path $expandedPath $file.Name)) {
                    $hasAnyFile = $true
                    break
                }
            }
            
            if ($hasAnyFile) {
                Write-Host "  [OK] Found at: $expandedPath" -ForegroundColor Green
                return $expandedPath
            }
        }
    }
    
    Write-Host "  [WARN] J-Link not found in standard locations" -ForegroundColor Yellow
    return $null
}

function Copy-JLinkFiles {
    Param([string]$SourceDir, [string]$DestDir, [bool]$ForceOverwrite)
    
    $copiedCount = 0
    $skippedCount = 0
    $missingCount = 0
    
    Write-Host "Copying J-Link files..." -ForegroundColor Cyan
    
    # 复制必需文件
    foreach ($file in $REQUIRED_FILES) {
        $srcPath = Join-Path $SourceDir $file.Name
        $destPath = Join-Path $DestDir $file.Name
        
        # 检查源文件是否存在
        if (-not (Test-Path $srcPath)) {
            Write-Host "  [MISS] Missing: $($file.Name) - $($file.Description)" -ForegroundColor Red
            $missingCount++
            continue
        }
        
        # 检查目标文件是否已存在
        if ((Test-Path $destPath) -and -not $ForceOverwrite) {
            Write-Host "  [SKIP] Skipped: $($file.Name) (already exists)" -ForegroundColor Gray
            $skippedCount++
            continue
        }
        
        # 复制文件
        try {
            Copy-Item -Path $srcPath -Destination $destPath -Force -ErrorAction Stop
            
            # 验证文件大小
            $srcSize = (Get-Item $srcPath).Length
            $destSize = (Get-Item $destPath).Length
            
            if ($srcSize -eq $destSize) {
                $sizeKB = [math]::Round($srcSize / 1KB, 1)
                Write-Host "  [OK]   Copied: $($file.Name) ($sizeKB KB)" -ForegroundColor Green
                $copiedCount++
            } else {
                Write-Host "  [WARN] Warning: $($file.Name) size mismatch" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "  [ERR]  Failed: $($file.Name) - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # 复制可选的 VC++ Runtime DLLs
    Write-Host ""
    Write-Host "Copying optional runtime libraries..." -ForegroundColor Cyan
    $runtimeCopied = 0
    $runtimeSkipped = 0
    
    foreach ($dllName in $OPTIONAL_RUNTIME_DLLS) {
        $srcPath = Join-Path $SourceDir $dllName
        $destPath = Join-Path $DestDir $dllName
        
        if (Test-Path $srcPath) {
            if ((Test-Path $destPath) -and -not $ForceOverwrite) {
                $runtimeSkipped++
            } else {
                try {
                    Copy-Item -Path $srcPath -Destination $destPath -Force -ErrorAction Stop
                    $runtimeCopied++
                } catch {
                    # 静默失败，运行时 DLL 不是关键
                }
            }
        }
    }
    
    if ($runtimeCopied -gt 0) {
        Write-Host "  [OK]   Copied $runtimeCopied runtime DLL(s)" -ForegroundColor Green
    }
    if ($runtimeSkipped -gt 0) {
        Write-Host "  [SKIP] Skipped $runtimeSkipped runtime DLL(s)" -ForegroundColor Gray
    }
    
    return @{
        Copied = $copiedCount
        Skipped = $skippedCount
        Missing = $missingCount
        Total = $REQUIRED_FILES.Count
    }
}

function Show-InstallGuide {
    Write-StatusBox "J-Link Installation Required" "Yellow"
    
    Write-Host "J-Link software not found on this system." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To use J-Link debugging, please:" -ForegroundColor White
    Write-Host "  1. Download J-Link Software Pack from:" -ForegroundColor Gray
    Write-Host "     $DOWNLOAD_URL" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  2. Install J-Link to the default location" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  3. Re-run this script:" -ForegroundColor Gray
    Write-Host "     .\scripts\download-jlink.ps1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Opening download page in browser..." -ForegroundColor Gray
    
    try {
        Start-Process $DOWNLOAD_URL -ErrorAction SilentlyContinue
    } catch {
        Write-Host "  [!] Failed to open browser. Please visit URL manually." -ForegroundColor Yellow
    }
}

function Show-Summary {
    Param([hashtable]$Stats, [string]$DestPath)
    
    Write-StatusBox "Setup Summary" "Cyan"
    
    Write-Host "Files processed: $($Stats.Total)" -ForegroundColor White
    Write-Host "  Copied:  $($Stats.Copied)" -ForegroundColor Green
    Write-Host "  Skipped: $($Stats.Skipped)" -ForegroundColor Gray
    Write-Host "  Missing: $($Stats.Missing)" -ForegroundColor $(if ($Stats.Missing -gt 0) { "Red" } else { "Gray" })
    Write-Host ""
    Write-Host "Target directory:" -ForegroundColor White
    Write-Host "  $DestPath" -ForegroundColor Cyan
    Write-Host ""
    
    if ($Stats.Copied -gt 0) {
        Write-Host "[OK] J-Link tools ready for use!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "  - Run environment check: .\scripts\check-env.ps1" -ForegroundColor Gray
        Write-Host "  - Start debugging: Press F5 in VS Code" -ForegroundColor Gray
    } elseif ($Stats.Missing -gt 0) {
        Write-Host "[WARN] Some files are missing from the J-Link installation." -ForegroundColor Yellow
        Write-Host "       Try reinstalling J-Link or check installation path." -ForegroundColor Yellow
    } else {
        Write-Host "[INFO] All files already present (use -Force to recopy)" -ForegroundColor Gray
    }
    
    Write-Host ""
}

# ============================================
#  Main Execution
# ============================================

Write-StatusBox "J-Link Setup for BasicDemo" "Cyan"

# Ensure destination directory exists
if (-not (Test-Path $DestDir)) {
    Write-Host "Creating destination directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
}

$destPath = (Resolve-Path $DestDir).Path

# Search for J-Link installation
$jlinkPath = Find-JLinkInstallation

if ($jlinkPath) {
    # Copy files
    $stats = Copy-JLinkFiles -SourceDir $jlinkPath -DestDir $destPath -ForceOverwrite $Force
    
    # Show summary
    Show-Summary -Stats $stats -DestPath $destPath
} else {
    # Show installation guide
    Show-InstallGuide
}
