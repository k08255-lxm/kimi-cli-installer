# Kimi CLI + Swap 一键安装工具包 🚀

一个完整的Linux系统工具包，包含Kimi CLI智能命令行工具的一键安装脚本和Swap内存配置的完整解决方案。

## 📦 包含的文件

### 🎯 核心脚本
- **`install_kimi_and_swap.sh`** (7.7KB) - 一键安装主脚本
- **`verify_install.sh`** (3.3KB) - 安装验证工具
- **`uninstall.sh`** (6.1KB) - 安全卸载工具

### 📚 文档指南
- **`README_INSTALL.md`** (6.4KB) - 完整安装指南
- **`QUICK_REFERENCE.md`** (2.8KB) - 快速参考卡片
- **`EXAMPLES.md`** (8.7KB) - 实际应用示例

## ✨ 核心功能

### 🤖 Kimi CLI 安装
- 自动检测Linux发行版（Debian/Ubuntu、CentOS/RHEL/Fedora、Arch）
- 安装uv包管理器（官方推荐，比pip更快更可靠）
- 自动安装Python 3.13（Kimi CLI要求）
- 一键安装Kimi CLI智能命令行工具
- 可选Zsh插件集成（提升Shell体验）
- 自动配置环境变量

### 💾 Swap 配置（可选）
- 智能检测内存大小并推荐Swap大小
- 支持手动指定Swap大小
- 自动创建Swap文件并配置开机自启
- 优化swappiness参数（推荐值为10）
- 查看当前Swap配置

## 🚀 极简安装

### 一键安装（推荐）

```bash
curl -LsSf https://raw.githubusercontent.com/k08255-lxm/kimi-cli-installer/main/install_kimi_and_swap.sh | bash
```

或

```bash
wget -qO- https://raw.githubusercontent.com/k08255-lxm/kimi-cli-installer/main/install_kimi_and_swap.sh | bash
```

### 分步安装

```bash
# 1. 下载脚本
curl -LsSf https://raw.githubusercontent.com/k08255-lxm/kimi-cli-installer/main/install_kimi_and_swap.sh -o install_kimi_and_swap.sh

# 2. 添加执行权限
chmod +x install_kimi_and_swap.sh

# 3. 运行脚本
./install_kimi_and_swap.sh
```

## 📊 功能特性

| 功能 | 说明 | 状态 |
|------|------|------|
| 发行版检测 | 自动识别Debian/Ubuntu/CentOS/Arch | ✅ |
| 依赖安装 | 自动安装系统依赖 | ✅ |
| UV安装 | 安装官方推荐的uv包管理器 | ✅ |
| Python 3.13 | 安装Kimi CLI所需Python版本 | ✅ |
| Kimi CLI | 安装智能命令行工具 | ✅ |
| Zsh集成 | 可选Oh My Zsh插件集成 | ✅ |
| Swap配置 | 智能Swap内存配置 | ✅ |
| 安装验证 | 验证安装状态的工具 | ✅ |
| 安全卸载 | 干净卸载所有组件 | ✅ |

## 📋 系统要求

- **操作系统**: Linux（支持systemd）
- **用户权限**: 普通用户 + sudo权限（不要直接用root）
- **磁盘空间**: 至少2GB可用空间
- **网络**: 需要互联网连接（离线环境见示例）
- **内存**: 建议至少1GB物理内存

## 🎯 快速开始

### 安装完成后

1. **启动Kimi CLI**:
```bash
kimi
```

2. **首次配置**:
在Kimi CLI中发送: `/setup`

3. **查看帮助**:
发送: `/help`

4. **切换模式**:
按 `Ctrl-X` 切换Agent模式和Shell模式

### 验证安装

```bash
# 运行验证脚本
./verify_install.sh
```

### 卸载（如果需要）

```bash
# 运行卸载脚本
./uninstall.sh
```

## 📖 详细文档

### 完整的安装指南
查看 [README_INSTALL.md](./README_INSTALL.md) 获取详细的安装说明、配置选项和故障排除。

### 快速参考
查看 [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) 获取常用命令速查表。

### 应用示例
查看 [EXAMPLES.md](./EXAMPLES.md) 获取不同场景下的实际使用示例：
- 云服务器初始配置
- 本地开发环境
- CI/CD自动化
- Docker容器配置
- 离线环境安装
- 系统恢复和重装

## 🛠️ 命令速查

### 核心命令

```bash
# 安装
./install_kimi_and_swap.sh

# 验证
./verify_install.sh

# 卸载
./uninstall.sh
```

### Kimi CLI 命令

```bash
kimi --version              # 查看版本
kimi --help                 # 查看帮助
kimi --shell                # Shell模式
kimi --mcp-config-file x    # 使用MCP配置
```

### Swap 管理

```bash
swapon --show               # 查看swap
free -h                     # 查看内存
sudo swapoff /swapfile      # 关闭swap
sudo swapon /swapfile       # 启用swap
```

## 🔧 高级配置

### 自定义Swap大小

脚本会根据内存自动推荐：
```
RAM < 2GB   → Swap: 2GB
RAM < 4GB   → Swap: 4GB
RAM < 8GB   → Swap: 8GB
RAM < 16GB  → Swap: 16GB
RAM >= 16GB → Swap: 32GB
```

### Zsh插件集成

如果使用Oh My Zsh：
1. 脚本会自动安装插件
2. 手动添加到 `~/.zshrc`:
```bash
plugins=(git zsh-autosuggestions kimi-cli)
```
3. 重启Zsh: `source ~/.zshrc`

## 🐛 故障排除

### 常见问题

1. **kimi: command not found**
```bash
source ~/.bashrc  # 或 source ~/.zshrc
```

2. **uv: command not found**
```bash
export PATH="$HOME/.cargo/bin:$PATH"
```

3. **Swap未启用**
```bash
sudo swapon /swapfile
```

4. **权限错误**
```bash
# 不要使用root用户运行
# 确保有sudo权限: sudo -l
```

### 运行验证

```bash
# 使用验证脚本
./verify_install.sh
```

## 📂 文件结构

```
.
├── install_kimi_and_swap.sh    # 主安装脚本
├── verify_install.sh           # 验证工具
├── uninstall.sh                # 卸载工具
├── README.md                   # 本文件
├── README_INSTALL.md           # 详细安装指南
├── QUICK_REFERENCE.md          # 快速参考卡片
└── EXAMPLES.md                 # 应用示例
```

## 🤝 贡献

欢迎提交Issue和Pull Request！

## 📄 许可证

MIT License - 可自由使用、修改和分发

## 🔗 相关链接

- [Kimi CLI官方文档](https://www.kimi.com/coding/docs/kimi-cli.html)
- [Kimi CLI GitHub](https://github.com/MoonshotAI/kimi-cli)
- [uv包管理器](https://docs.astral.sh/uv/)
- [Swap配置最佳实践](https://wiki.archlinux.org/title/Swap)

## 💡 使用建议

### ✅ 推荐场景

1. **新系统初始化**: 一键安装开发环境
2. **云服务器**: 自动配置Swap + Kimi CLI
3. **开发环境**: 集成Zsh，提升效率
4. **CI/CD**: 自动化安装，跳过交互
5. **系统恢复**: 快速重建环境

### 📊 性能建议

- **Swap大小**: 根据实际内存和工作负载调整
- **Swappiness**: 服务器推荐10，桌面推荐60
- **定期监控**: 使用`free -h`监控内存和Swap
- **避免过度交换**: 确保有足够的物理内存

## 🎉 开始使用

```bash
# 1. 下载并运行
curl -LsSf https://raw.githubusercontent.com/k08255-lxm/kimi-cli-installer/main/install_kimi_and_swap.sh | bash

# 2. 验证安装
./verify_install.sh

# 3. 启动Kimi CLI
kimi

# 4. 初始配置
# 在Kimi CLI中输入: /setup

# 5. 开始智能编程🚀
```

---

**享受Kimi CLI带来的智能命令行体验！**

如有问题，请查看详细文档或提交Issue。
