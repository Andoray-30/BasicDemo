# PowerShell 脚本使用说明

## 常见问题

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

## 脚本说明

### load-user-env.ps1
从 `user.mk` 读取并设置环境变量

```powershell
. .\scripts\load-user-env.ps1
```

### check-env.ps1
检查开发工具是否可用

```powershell
.\scripts\check-env.ps1
```

### generate-vscode-env.ps1
生成 `.vscode/.env` 文件

```powershell
.\scripts\generate-vscode-env.ps1
```

## 参考

- [PowerShell 执行策略](https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_execution_policies)
- [PowerShell 7 下载](https://github.com/PowerShell/PowerShell/releases)

