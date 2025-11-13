#!/bin/bash

# 一键安装脚本: Kimi CLI + 可选Swap配置
# 适用于全新安装或不全新的Linux系统
# 支持: Debian/Ubuntu, CentOS/RHEL/Fedora, Arch Linux

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的信息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "请不要以root用户运行此脚本！请使用普通用户并确保有sudo权限"
        exit 1
    fi
}

# 检测Linux发行版
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
    else
        print_error "无法检测Linux发行版"
        exit 1
    fi
    print_info "检测到系统: $DISTRO $VERSION"
}

# 安装依赖包
install_dependencies() {
    print_info "正在安装系统依赖..."
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y curl wget python3 python3-dev python3-pip build-essential
            ;;
        centos|rhel|fedora)
            sudo yum install -y curl wget python3 python3-devel gcc make
            ;;
        arch)
            sudo pacman -Sy --noconfirm curl wget python3 base-devel
            ;;
        *)
            print_error "不支持的发行版: $DISTRO"
            exit 1
            ;;
    esac
    
    print_success "系统依赖安装完成"
}

# 安装uv包管理器
install_uv() {
    if command -v uv &> /dev/null; then
        print_info "uv已安装，版本: $(uv --version)"
        return 0
    fi
    
    print_info "正在安装uv包管理器..."
    
    # 使用官方安装脚本
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # 将uv添加到PATH
    export PATH="$HOME/.cargo/bin:$PATH"
    
    # 添加到shell配置
    SHELL_CONFIG=""
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    fi
    
    if [ -n "$SHELL_CONFIG" ]; then
        echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$SHELL_CONFIG"
        print_info "已将uv路径添加到 $SHELL_CONFIG"
    fi
    
    # 重新加载配置
    if [ -n "$SHELL_CONFIG" ]; then
        source "$SHELL_CONFIG"
    fi
    
    # 验证安装
    if command -v uv &> /dev/null; then
        print_success "uv安装成功，版本: $(uv --version)"
    else
        print_error "uv安装失败"
        exit 1
    fi
}

# 安装Kimi CLI
install_kimi_cli() {
    print_info "正在安装Kimi CLI..."
    
    # 确保uv在PATH中
    export PATH="$HOME/.cargo/bin:$PATH"
    
    # 安装Python 3.13（如果不存在）
    if ! command -v python3.13 &> /dev/null; then
        print_warning "Python 3.13未找到，将使用uv安装..."
        uv python install 3.13
    fi
    
    # 安装kimi-cli
    uv tool install --python 3.13 kimi-cli
    
    # 检查安装
    if command -v kimi &> /dev/null; then
        print_success "Kimi CLI安装成功，版本: $(kimi --version)"
        echo ""
        print_info "首次使用请运行: kimi"
        print_info "然后在Kimi CLI中发送: /setup"
        print_info "配置完成后可以使用: /help 获取更多帮助"
    else
        print_error "Kimi CLI安装失败"
        exit 1
    fi
}

# 配置Zsh插件（可选）
setup_zsh_plugin() {
    if [ -n "$ZSH_VERSION" ]; then
        print_info "检测到Zsh，是否安装Kimi CLI插件？(y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
            git clone https://github.com/MoonshotAI/zsh-kimi-cli.git \
                "$ZSH_CUSTOM/plugins/kimi-cli"
            
            print_info "请将 'kimi-cli' 添加到 ~/.zshrc 的 plugins 列表中"
            print_info "例如: plugins=(git zsh-autosuggestions kimi-cli)"
            print_info "然后运行: source ~/.zshrc 或重启终端"
        fi
    fi
}

# 检查当前swap配置
check_swap() {
    print_info "当前Swap配置:"
    swapon --show | head -5 || echo "无swap分区"
    free -h | grep -E "Mem|Swap"
}

# 配置swap
setup_swap() {
    print_info "是否需要配置Swap分区？(y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        return 0
    fi
    
    print_info "请选择Swap配置方式:"
    echo "1) 自动配置 (推荐，基于内存大小)"
    echo "2) 手动配置指定大小"
    echo "3) 查看当前配置后退出"
    read -r choice
    
    case $choice in
        1)
            configure_swap_auto
            ;;
        2)
            configure_swap_manual
            ;;
        3)
            check_swap
            return 0
            ;;
        *)
            print_error "无效选项"
            return 1
            ;;
    esac
}

# 自动配置swap
configure_swap_auto() {
    # 获取内存大小(GB)
    MEM_GB=$(free -g | awk '/^Mem:/{print $2}')
    
    if [ "$MEM_GB" -lt 2 ]; then
        SWAP_SIZE=2
    elif [ "$MEM_GB" -lt 4 ]; then
        SWAP_SIZE=4
    elif [ "$MEM_GB" -lt 8 ]; then
        SWAP_SIZE=8
    elif [ "$MEM_GB" -lt 16 ]; then
        SWAP_SIZE=16
    else
        SWAP_SIZE=32
    fi
    
    print_info "内存: ${MEM_GB}GB, 推荐Swap: ${SWAP_SIZE}GB"
    configure_swap_file "$SWAP_SIZE"
}

# 手动配置swap
configure_swap_manual() {
    echo -n "请输入Swap大小 (GB): "
    read -r SWAP_SIZE
    
    if ! [[ "$SWAP_SIZE" =~ ^[0-9]+$ ]] || [ "$SWAP_SIZE" -lt 1 ]; then
        print_error "请输入有效的正整数"
        return 1
    fi
    
    configure_swap_file "$SWAP_SIZE"
}

# 配置swap文件
configure_swap_file() {
    local size_gb=$1
    local swap_file="/swapfile"
    
    print_info "正在配置 ${size_gb}GB swap文件..."
    
    # 检查是否已有swap
    if swapon --show | grep -q "$swap_file"; then
        print_warning "检测到已有的swap，将先关闭..."
        sudo swapoff "$swap_file" || true
    fi
    
    # 创建swap文件
    sudo dd if=/dev/zero of="$swap_file" bs=1G count="$size_gb" status=progress
    sudo chmod 600 "$swap_file"
    sudo mkswap "$swap_file"
    sudo swapon "$swap_file"
    
    # 添加到fstab
    if ! grep -q "$swap_file" /etc/fstab; then
        echo "$swap_file none swap sw 0 0" | sudo tee -a /etc/fstab
    fi
    
    print_success "Swap配置完成!"
    check_swap
    
    # 调整swappiness
    print_info "调整swappiness值为10（推荐值）..."
    echo "10" | sudo tee /proc/sys/vm/swappiness
    echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
}

# 主函数
main() {
    echo "=========================================="
    echo "   Kimi CLI + Swap 一键安装配置脚本"
    echo "   支持: Debian/Ubuntu/CentOS/Arch"
    echo "=========================================="
    echo ""
    
    # 检查root权限
    check_root
    
    # 检测发行版
    detect_distro
    
    # 显示当前swap状态
    check_swap
    echo ""
    
    # 安装系统依赖
    install_dependencies
    echo ""
    
    # 安装uv
    install_uv
    echo ""
    
    # 安装kimi cli
    install_kimi_cli
    echo ""
    
    # 配置zsh插件（可选）
    setup_zsh_plugin
    echo ""
    
    # 配置swap（可选）
    setup_swap
    echo ""
    
    # 完成
    print_success "安装配置完成!"
    echo ""
    echo "快速开始:"
    echo "1. 运行: kimi"
    echo "2. 发送: /setup 进行初始配置"
    echo "3. 使用: /help 查看帮助"
    echo ""
    echo "如果想要切换Shell模式，在Kimi CLI中按 Ctrl-X"
}

# 运行主函数
main "$@"
