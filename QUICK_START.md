# 快速开始指南

## 首次使用

### 1. 解决脚本运行问题

如果遇到"无法运行脚本"错误：

```powershell
# 允许运行脚本
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

或双击运行：`setup-env.bat`

### 2. 配置工具链

```powershell
# 复制配置模板
Copy-Item user.mk.example user.mk

# 编辑路径
notepad user.mk
```

### 3. 检查环境

```powershell
.\scripts\check-env.ps1
```

## 所需工具

| 工具 | 下载 |
|------|------|
| ARM GCC | [下载](https://developer.arm.com/downloads/-/gnu-rm) |
| MinGW Make | [下载](https://www.mingw-w64.org/downloads/) |
| J-Link (可选) | [下载](https://www.segger.com/downloads/jlink/) |
| OpenOCD (可选) | [下载](https://github.com/xpack-dev-tools/openocd-xpack/releases) |

## VS Code 使用

- 编译: `Ctrl+Shift+B`
- 调试: `F5`

## 常见问题

### 环境变量未生效？

```powershell
# 注意前面有点和空格
. .\scripts\load-user-env.ps1
```

### 工具找不到？

检查 `user.mk` 中的路径是否正确

---

详细文档: [README.md](README.md) | [scripts/README.md](scripts/README.md)

