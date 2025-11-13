# Kimi CLI + Swap 一键安装配置脚本

一个功能强大的一键安装脚本，用于在Linux系统上快速安装Kimi CLI智能命令行工具，并可选择性地配置Swap分区。

## 支持的系统

- **Debian/Ubuntu** (含所有衍生版)
- **CentOS/RHEL/Fedora** (含所有衍生版)
- **Arch Linux** (含所有衍生版)
- 其他使用systemd的现代Linux发行版

## 功能特点

### 🚀 Kimi CLI 安装
- 自动安装uv包管理器（官方推荐）
- 安装Python 3.13（Kimi CLI要求）
- 一键安装Kimi CLI智能命令行工具
- 可选Zsh插件集成（Oh My Zsh用户）
- 自动配置环境变量

### 💾 Swap 配置（可选）
- 智能检测内存大小并推荐合适的Swap大小
- 支持手动指定Swap大小
- 自动创建Swap文件并配置开机自启
- 优化swappiness参数
- 查看当前Swap配置

## 快速开始

### 一键安装

```bash
curl -LsSf https://raw.githubusercontent.com/k08255-lxm/kimi-cli-installer/install_kimi_and_swap.sh -o install_kimi_and_swap.sh
chmod +x install_kimi_and_swap.sh
./install_kimi_and_swap.sh
```

或者使用wget：

```bash
wget https://raw.githubusercontent.com/k08255-lxm/kimi-cli-installer/install_kimi_and_swap.sh
chmod +x install_kimi_and_swap.sh
./install_kimi_and_swap.sh
```

> **注意**: 请确保您有sudo权限，但不要使用root用户直接运行此脚本。

## 详细安装说明

### 方式1: 直接下载运行

1. 下载脚本：
```bash
curl -LsSf https://raw.githubusercontent.com/k08255-lxm/kimi-cli-installer/install_kimi_and_swap.sh -o install_kimi_and_swap.sh
```

2. 添加执行权限：
```bash
chmod +x install_kimi_and_swap.sh
```

3. 运行脚本（使用普通用户，非root）：
```bash
./install_kimi_and_swap.sh
```

### 方式2: 从本仓库安装

```bash
git clone https://github.com/k08255-lxm/kimi-cli-installer/kimi-cli-installer.git
cd kimi-cli-installer
chmod +x install_kimi_and_swap.sh
./install_kimi_and_swap.sh
```

## 功能详解

### 📥 Kimi CLI 安装流程

1. **系统检测**: 自动识别Linux发行版
2. **依赖安装**: 安装curl、wget、Python3、build工具等
3. **UV安装**: 安装uv包管理器（相比pip更快更可靠）
4. **Python 3.13**: 安装Kimi CLI所需的Python版本
5. **Kimi CLI**: 使用uv安装kimi-cli包
6. **环境配置**: 自动配置PATH环境变量
7. **Zsh插件**: 为Zsh用户提供可选插件集成

### 💾 Swap 配置流程

安装完成后，脚本会询问是否需要配置Swap：

#### 自动配置
根据内存大小智能推荐Swap大小：
- 内存 < 2GB: Swap = 2GB
- 内存 < 4GB: Swap = 4GB
- 内存 < 8GB: Swap = 8GB
- 内存 < 16GB: Swap = 16GB
- 内存 >= 16GB: Swap = 32GB

#### 手动配置
自定义Swap大小（最小1GB）

#### Swap配置包括
- 创建指定大小的Swap文件
- 设置正确权限
- 格式化Swap文件
- 启用Swap
- 配置开机自动挂载
- 优化swappiness参数为10

## 使用Kimi CLI

安装完成后，按以下步骤开始使用：

1. **启动Kimi CLI**: 
```bash
kimi
```

2. **初始配置**: 在Kimi CLI中发送 `/setup` 命令

3. **查看帮助**: 发送 `/help` 获取更多信息

4. **切换模式**: 在Kimi CLI中按 `Ctrl-X` 切换Shell模式

### 基本命令

```bash
# 查看版本
kimi --version

# 启动交互模式
kimi

# 在Shell模式运行命令
kimi --shell

# 使用MCP配置
kimi --mcp-config-file /path/to/mcp.json
```

## Zsh插件集成

如果使用Oh My Zsh，脚本会询问是否安装Zsh插件：

1. 脚本会自动克隆插件到 `~/.oh-my-zsh/custom/plugins/kimi-cli`
2. 手动将 `kimi-cli` 添加到 `~/.zshrc` 的 plugins 列表：
```bash
plugins=(git zsh-autosuggestions kimi-cli)
```
3. 重启Zsh: `source ~/.zshrc`

现在可以按 `Ctrl-X` 在Zsh中直接进入Kimi CLI的agent模式。

## Swap管理指南

### 手动调整swap

脚本配置完成后，可以手动管理Swap：

```bash
# 查看当前swap状态
swapon --show
free -h

# 禁用swap
sudo swapoff /swapfile

# 启用swap
sudo swapon /swapfile

# 修改swappiness（0-100）
echo 10 | sudo tee /proc/sys/vm/swappiness
```

### 修改Swap大小

如果需要修改Swap大小，重新运行脚本或手动操作：

```bash
# 1. 禁用当前swap
sudo swapoff /swapfile

# 2. 删除原文件
sudo rm /swapfile

# 3. 重新运行脚本
./install_kimi_and_swap.sh
```

## 故障排除

### 问题1: 无法下载脚本

如果使用curl/wget下载失败，尝试：
```bash
wget --no-check-certificate https://raw.githubusercontent.com/k08255-lxm/kimi-cli-installer/install_kimi_and_swap.sh
```

### 问题2: uv安装失败

- 确保网络连接正常
- 检查SSL证书: `curl -v https://astral.sh`
- 手动安装uv: `curl -LsSf https://astral.sh/uv/install.sh | sh`

### 问题3: Kimi CLI安装失败

- 确保uv正确安装: `which uv`
- 检查Python 3.13: `uv python list`
- 手动安装: `uv tool install --python 3.13 kimi-cli`

### 问题4: Swap配置失败

- 检查磁盘空间: `df -h /`
- 确保没有同名文件: `ls -la /swapfile`
- 手动删除: `sudo rm -f /swapfile`

### 问题5: 权限问题

- 不要以root用户运行脚本
- 确保用户有sudo权限: `sudo -l`

## 高级配置

### 自定义安装路径

如需自定义uv安装路径，设置环境变量：
```bash
export UV_INSTALL_DIR="$HOME/custom/uv"
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 离线安装

1. 在有网络的机器下载安装包：
```bash
curl -LsSf https://astral.sh/uv/install.sh -o uv-install.sh
curl -LsSf https://astral.sh/uv/uv-installer.sh -o uv-installer.sh
```

2. 复制到目标机器并运行：
```bash
chmod +x uv-install.sh uv-installer.sh
./uv-install.sh
```

## 系统要求

- **操作系统**: Linux (支持systemd)
- **用户权限**: 普通用户 + sudo权限
- **磁盘空间**: 至少2GB可用空间
- **网络**: 需要互联网连接
- **内存**: 建议至少1GB物理内存

## 更新日志

### v1.0.0 (2025-11-13)
- 初始版本发布
- 支持多Linux发行版
- 集成Kimi CLI安装
- 集成Swap配置功能
- 支持Zsh插件集成
- 智能内存检测

## 许可证

MIT License - 可自由使用、修改和分发

## 贡献

欢迎提交Issue和Pull Request！

## 相关链接

- [Kimi CLI官方文档](https://www.kimi.com/coding/docs/kimi-cli.html)
- [Kimi CLI GitHub](https://github.com/MoonshotAI/kimi-cli)
- [uv包管理器](https://docs.astral.sh/uv/)
- [Swap配置最佳实践](https://wiki.archlinux.org/title/Swap)

## 作者

由ChatGPT辅助创建，为Linux用户打造极致便捷体验

---

**享受Kimi CLI带来的智能命令行体验吧！** 🚀
