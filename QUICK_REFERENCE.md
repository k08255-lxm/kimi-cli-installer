# 🚀 Kimi CLI + Swap 快速参考卡片

## 极简安装命令

```bash
curl -LsSf https://raw.githubusercontent.com/k08255-lxm/kimi-cli-installer/install_kimi_and_swap.sh | bash
```

or

```bash
wget -qO- https://raw.githubusercontent.com/k08255-lxm/kimi-cli-installer/install_kimi_and_swap.sh | bash
```

## 安装后快速开始

### 1. 启动Kimi CLI
```bash
kimi
```

### 2. 首次配置
在Kimi CLI中输入：
```
/setup
```

### 3. 获取帮助
```
/help
```

### 4. 切换模式
按 `Ctrl-X` 在Agent模式和Shell模式间切换

## 常用命令备忘

### Kimi CLI 命令
```bash
kimi --version              # 查看版本
kimi --help                 # 查看帮助
kimi --shell                # Shell模式
kimi --mcp-config-file x    # 使用MCP配置
kimi --acp                  # Agent Client Protocol模式
```

### Swap 管理命令
```bash
swapon --show               # 查看所有swap
free -h                     # 查看内存和swap
sudo swapoff /swapfile      # 关闭swap
sudo swapon /swapfile       # 启用swap
cat /proc/sys/vm/swappiness # 查看swappiness
```

### 系统信息
```bash
df -h                       # 磁盘空间
du -sh /swapfile            # swap文件大小
ls -lh /swapfile            # swap文件详情
```

## 故障速查

| 问题 | 解决方案 |
|------|----------|
| `kimi: command not found` | 运行 `source ~/.bashrc` 或 `source ~/.zshrc` |
| `uv: command not found` | 检查 `~/.cargo/bin` 是否在PATH中 |
| swap无法启用 | 检查磁盘空间 `df -h /` |
| 权限错误 | 不要使用root用户，用sudo权限的普通用户 |
| 网络超时 | 检查网络，或手动设置代理 |

## 配置速览

### 推荐Swap大小
```
RAM < 2GB   → Swap: 2GB
RAM < 4GB   → Swap: 4GB
RAM < 8GB   → Swap: 8GB
RAM < 16GB  → Swap: 16GB
RAM >= 16GB → Swap: 32GB
```

### 推荐swappiness
```
vm.swappiness=10  # 优先使用物理内存
```

## Zsh用户特别配置

1. 添加插件到 `~/.zshrc`：
```bash
plugins=(... kimi-cli)
```

2. 重启Zsh：
```bash
source ~/.zshrc
```

3. 在Zsh中按 `Ctrl-X` 直接进入Kimi CLI

## 安全提示

✅ **要做的:**
- 使用普通用户运行脚本
- 确保有sudo权限
- 使用最新版本脚本
- 检查脚本内容后再运行

❌ **不要做的:**
- 不要使用root直接运行
- 不要跳过依赖检查
- 不要忽略错误信息

## 资源链接

- 📚 完整文档: [README_INSTALL.md](./README_INSTALL.md)
- 🐙 GitHub: [https://github.com/MoonshotAI/kimi-cli](https://github.com/MoonshotAI/kimi-cli)
- 🔧 uv文档: [https://docs.astral.sh/uv/](https://docs.astral.sh/uv/)

## 一键卸载

如需卸载：
```bash
# 卸载Kimi CLI
uv tool uninstall kimi-cli

# 禁用并删除swap
sudo swapoff /swapfile
sudo rm -f /swapfile
sudo sed -i '/swapfile/d' /etc/fstab

# 卸载uv
rm -rf ~/.cargo/bin/uv ~/.uv
```

---

**版本**: v1.0.0  
**更新时间**: 2025-11-13
