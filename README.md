# STM32F103 BasicDemo

基于 STM32F103C8T6 的嵌入式开发项目 | ARM GNU Toolchain + mingw32-make

---

##  开发环境

- **芯片**: STM32F103C8T6 (Cortex-M3, 64KB Flash, 20KB RAM)
- **工具链**: ARM GNU Toolchain (arm-none-eabi-gcc)
- **构建**: mingw32-make
- **调试**: OpenOCD / J-Link GDB Server
- **IDE**: VS Code + Cortex-Debug

---

## ⚡ 快速开始

### 首次使用三步走

#### 第一步：一键配置环境

**方式一：自动设置（推荐）**

```powershell
.\setup.ps1  # 或双击 setup-env.bat
```

**方式二：手动设置**

```powershell
# 1. 允许运行脚本
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# 2. 复制配置模板
Copy-Item user.mk.example user.mk

# 3. 编辑工具链路径
notepad user.mk
```

> 💡 **首次使用必读**: 如果遇到"无法运行脚本"错误,运行 `Set-ExecutionPolicy` 命令即可解决

#### 第二步：检查开发工具

```powershell
.\scripts\check-env.ps1
```

**所需工具下载**:

| 工具 | 用途 | 下载链接 |
|------|------|----------|
| ARM GCC | 编译器 | [ARM官网下载](https://developer.arm.com/downloads/-/gnu-rm) |
| MinGW Make | 构建工具 | [MinGW下载](https://www.mingw-w64.org/downloads/) |
| OpenOCD (可选) | ST-Link调试 | [OpenOCD下载](https://github.com/xpack-dev-tools/openocd-xpack/releases) |
| J-Link (可选) | J-Link调试 | [SEGGER下载](https://www.segger.com/downloads/jlink/) |

#### 第三步：开始开发

- **编译**: `Ctrl+Shift+B` 或 `mingw32-make -j24`
- **调试**: `F5` 启动调试
- **烧录**: 见下方调试配置说明

---

## 📖 详细使用指南

### 环境配置说明

`user.mk` 用于存放本地工具链路径,避免修改仓库文件:

```makefile
# user.mk 示例配置
GCC_PATH = F:/arm-toolchain/bin
SEGGER_JLINK_DIR = F:/SEGGER/Jlink
MAKE = mingw32-make
MAKE_JOBS = 24
```

**VS Code 自动加载**: 集成终端已配置自动执行 `load-user-env.ps1`,打开新终端即可使用环境变量。

**手动加载**（外部 PowerShell）:

```powershell
. .\scripts\load-user-env.ps1
```

### 编译项目

**快速编译（并行）:**

```powershell
mingw32-make -j24
```

**完全重新编译:**

```powershell
mingw32-make clean; mingw32-make -j24
```

**查看编译详情:**

```powershell
mingw32-make V=1
```

### 调试

- 连接调试器（ST-Link / J-Link）到开发板
- 按 **F5** 启动调试
- 选择对应配置（推荐 `OpenOCD ST-Link` 或 `J-Link`）

### 烧录（不调试）

**使用 ST-Link:**

```powershell
openocd -f interface/stlink.cfg -f .vscode/stm32f1x_custom.cfg -c "program build/BasicDemo.elf verify reset exit"
```

---

## 📋 常用命令速查

| 命令 | 说明 |
|------|------|
| `mingw32-make -j24` | 并行编译（推荐：CPU核心数2） |
| `mingw32-make clean` | 清理编译产物 |
| `arm-none-eabi-size build/BasicDemo.elf` | 查看程序大小 |
| `arm-none-eabi-objdump -d build/BasicDemo.elf > build/disasm.txt` | 生成反汇编 |

**内存限制**:

- Flash: 64 KB (text + data < 65536 字节)
- RAM: 20 KB (data + bss < 20480 字节)

---

## 🔧 调试配置

项目已配置多种调试方式，按 **F5** 启动调试：

### 调试器选择

| 配置名称 | 调试器硬件 | 推荐度 | 说明 |
|---------|----------|--------|------|
| **OpenOCD ST-Link** | ST-Link V2/V3 |  | 最常用，价格便宜，稳定 |
| **OpenOCD DAPlink** | CMSIS-DAP |  | 开源调试器，跨平台好 |
| **J-Link** | SEGGER J-Link |  | 速度最快，功能最强（需正版） |
| **J-Link (Generic)** | SEGGER J-Link |  | 兼容模式，芯片识别失败时使用 |
| **J-Link (Under Reset)** | SEGGER J-Link |  | 芯片锁死或低功耗时使用 |
| **DAPlink-Attach** | CMSIS-DAP |  | 附加到运行中的程序 |
| **J-Link-Attach** | SEGGER J-Link |  | 附加模式，不复位芯片 |

详细配置说明请查看 `.vscode/launch.json` 中的注释。

---

## ❓ 常见问题

### PowerShell 脚本

**Q: 无法运行脚本？**  
A: 运行 `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`

详见：[scripts/README.md](scripts/README.md)

### 编译相关

**Q: 编译速度慢？**  
A: 使用并行编译 `mingw32-make -j24`（建议设置为 CPU 核心数2）

**Q: 提示 "No rule to make target"？**  
A: 文件路径错误或不存在，检查 Makefile 源文件列表

**Q: 修改头文件后未重新编译？**  
A: 使用 `mingw32-make clean; mingw32-make -j24` 强制重编译

### 调试相关

**OpenOCD 报错 "UNEXPECTED idcode"**  
 已配置 `.vscode/stm32f1x_custom.cfg` 自动兼容所有芯片 ID

**无法连接调试器**  
检查清单:

- ST-Link 驱动是否安装
- USB 连接是否正常
- 目标板供电（3.3V）
- SWDIO/SWCLK 连接正确

**编译后无法烧录**  
可能原因:

- Flash 超限（检查 `text + data` < 64KB）
- 程序禁用调试接口（使用 Connect Under Reset 模式）

---

## 📁 项目结构

```plaintext
BasicDemo/
 build/              # 编译输出 (elf/hex/bin)
 Core/
    Inc/           # 头文件
    Src/           # 源文件 (main.c, gpio.c...)
 Drivers/
    CMSIS/
    STM32F1xx_HAL_Driver/
 .vscode/           # VS Code 配置
    launch.json    # 调试配置
    tasks.json     # 构建任务
    settings.json  # 终端自动加载 user.mk
 scripts/
    check-env.ps1          # 检查工具链
    load-user-env.ps1      # 加载环境变量
    generate-vscode-env.ps1
 Makefile
 user.mk            # 本地配置（不提交仓库）
 user.mk.example    # 配置模板
```

---

## 📚 参考资料

- [STM32F103 数据手册](https://www.st.com/resource/en/datasheet/stm32f103c8.pdf)
- [STM32F103 参考手册](https://www.st.com/resource/en/reference_manual/cd00171190.pdf)
- [ARM GCC 工具链文档](https://gcc.gnu.org/onlinedocs/)
- [OpenOCD 用户手册](http://openocd.org/doc/html/index.html)
- [Cortex-Debug 扩展](https://github.com/Marus/cortex-debug)

---

## 📄 许可证

本项目基于 ST 提供的 HAL 库和 CMSIS 库开发，遵循相应的开源许可证。
