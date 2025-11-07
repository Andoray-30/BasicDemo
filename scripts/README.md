# Scripts 目录说明

本目录包含项目环境配置和工具检查脚本。**已进行模块化整合**，所有脚本共享统一的核心功能。

---

## 📦 核心模块

### `env-manager.ps1` ⭐ 新增
**统一环境管理模块**，提供可复用的核心功能：

- **Parse-UserMk**: 解析 `user.mk` 文件，展开变量引用
- **Import-UserEnv**: 加载环境变量到 PowerShell 会话
- **Export-VscodeEnv**: 生成 `.vscode/.env` 文件
- **Test-Tool**: 检查工具是否可用

其他脚本通过导入此模块复用功能，避免重复代码。

---

## 🚀 用户脚本

### `load-user-env.ps1`
**加载环境变量到当前终端**

```powershell
# 在终端中运行（注意前面的点和空格）
. .\scripts\load-user-env.ps1
```

- 从 `user.mk` 读取配置
- 设置环境变量（`GCC_PATH`、`OPENOCD_PATH` 等）
- 自动将工具路径添加到 `PATH`
- **VS Code 终端会自动执行此脚本**（见 `.vscode/settings.json`）

### `check-env.ps1`
**检查开发工具是否可用**

```powershell
.\scripts\check-env.ps1
```

输出示例：
```
Checking development tools...
[OK]     arm-none-eabi-gcc
[OK]     mingw32-make
[MISSING] JLink
[OK]     openocd
```

### `generate-vscode-env.ps1`
**生成 .vscode/.env 文件**

```powershell
.\scripts\generate-vscode-env.ps1
```

- 从 `user.mk` 生成标准 `.env` 格式
- 供其他 VS Code 扩展或工具使用
- **注意**：当前调试配置使用 `${workspaceFolder}` 相对路径，不强制依赖 `.env`

### `download-jlink.ps1` ⭐ 重写增强
**设置项目级 J-Link 工具**

```powershell
# 标准设置（从系统安装复制）
.\scripts\download-jlink.ps1

# 强制重新复制（覆盖已有文件）
.\scripts\download-jlink.ps1 -Force

# 查看详细帮助
Get-Help .\scripts\download-jlink.ps1 -Detailed
```

**新增功能**：
- ✅ 智能搜索 J-Link 安装路径（支持环境变量 + 多个标准路径）
- ✅ 文件完整性验证（大小校验）
- ✅ 详细状态报告（已复制/跳过/缺失）
- ✅ 友好的安装引导（未找到时）
- ✅ 防重复复制（已存在则跳过，除非使用 `-Force`）
- ✅ 完整的帮助文档（`Get-Help` 支持）

**必需文件**：
- `JLink.exe` - J-Link Commander
- `JLinkGDBServerCL.exe` - GDB 调试服务器
- `JlinkRTTClient.exe` - RTT 日志客户端
- `JLinkARM.dll` - J-Link 核心库 (~22 MB) ⚠️ 必需
- `JLink_x64.dll` - J-Link 64位库 (~24 MB) ⚠️ 必需

**运行时依赖**（自动复制）：
- VC++ Runtime DLLs (vcruntime140.dll, msvcp140.dll 等)

**磁盘占用**：约 48 MB（包含所有依赖）

**许可提示**：
⚠️ J-Link 软件为 SEGGER 专有软件，请勿在公开仓库中分发二进制文件。每位开发者需拥有有效的 J-Link 许可。

---

## 📋 对比：整合前后

| 功能 | 整合前 | 整合后 |
|------|--------|--------|
| **user.mk 解析** | 每个脚本都有独立实现 | 统一在 `env-manager.ps1` |
| **变量展开** | 重复代码 | 单一实现，支持嵌套引用 |
| **环境加载** | `load-user-env.ps1` 独立 | 调用 `Import-UserEnv` 函数 |
| **.env 生成** | `generate-vscode-env.ps1` 独立 | 调用 `Export-VscodeEnv` 函数 |
| **工具检查** | 内联函数 | 调用 `Test-Tool` 函数 |
| **代码行数** | ~150 行（重复） | ~230 行（含文档，无重复） |
| **维护性** | 修改需同步多处 | 修改只需改核心模块 |

---

## ⚠️ 常见问题

### 问题：无法运行脚本

**错误信息：**
```
无法加载文件，因为在此系统上禁止运行脚本
```

**解决方法（任选其一）：**

```powershell
# 方法1：临时允许（推荐）
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 方法2：永久允许
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# 方法3：运行 setup.ps1 自动配置
.\setup.ps1
```

### 问题：环境变量未生效

**错误做法：**
```powershell
.\scripts\load-user-env.ps1  # ❌ 子进程运行，无效
```

**正确做法：**
```powershell
. .\scripts\load-user-env.ps1  # ✅ 注意前面有点和空格
```

---

## 🔧 开发者指南

### 添加新脚本
如果需要创建新的环境相关脚本：

```powershell
# 导入核心模块
$modulePath = Join-Path $PSScriptRoot "env-manager.ps1"
. $modulePath

# 使用提供的函数
$vars = Parse-UserMk -UserMkPath "user.mk"
Import-UserEnv -AddToPath $true
Export-VscodeEnv -OutFile ".vscode/.env"
```

### 修改 user.mk 解析逻辑
只需编辑 `env-manager.ps1` 中的 `Parse-UserMk` 函数，所有脚本自动生效。

---

## 📚 参考资料

- [PowerShell 执行策略](https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_execution_policies)
- [PowerShell 7 下载](https://github.com/PowerShell/PowerShell/releases)

