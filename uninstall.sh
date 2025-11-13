#!/bin/bash

# Kimi CLI + Swap 卸载脚本
# 安全卸载已安装的组件

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

echo "========================================"
echo "   Kimi CLI + Swap 卸载工具"
echo "========================================"
echo ""

# 卸载Kimi CLI
uninstall_kimi() {
    print_info "正在卸载 Kimi CLI..."
    
    if command -v uv &> /dev/null; then
        if uv tool list | grep -q kimi-cli; then
            uv tool uninstall kimi-cli
            print_success "Kimi CLI 已卸载"
        else
            print_warning "Kimi CLI 未安装"
        fi
    else
        print_warning "uv 未安装，跳过 Kimi CLI 卸载"
    fi
}

# 卸载uv
uninstall_uv() {
    print_info "正在卸载 uv 包管理器..."
    
    read -p "是否同时卸载 uv 包管理器？(y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        UV_PATH="$HOME/.cargo/bin/uv"
        UV_DIR="$HOME/.uv"
        
        if [ -f "$UV_PATH" ]; then
            rm -f "$UV_PATH"
            rm -rf "$UV_DIR"
            
            # 从shell配置中移除
            SHELL_CONFIG=""
            if [ -n "$ZSH_VERSION" ]; then
                SHELL_CONFIG="$HOME/.zshrc"
            elif [ -n "$BASH_VERSION" ]; then
                SHELL_CONFIG="$HOME/.bashrc"
            fi
            
            if [ -n "$SHELL_CONFIG" ] && [ -f "$SHELL_CONFIG" ]; then
                sed -i '/\.cargo\/bin/d' "$SHELL_CONFIG"
                print_info "已从 $SHELL_CONFIG 移除 uv PATH"
            fi
            
            print_success "uv 包管理器已卸载"
        else
            print_warning "uv 未找到"
        fi
    else
        print_info "保留 uv 包管理器"
    fi
}

# 禁用并删除Swap
uninstall_swap() {
    print_info "正在处理 Swap 配置..."
    
    # 检查是否有swap
    if swapon --show | grep -q "/swapfile"; then
        read -p "是否禁用并删除 /swapfile？ (y/n): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo swapoff /swapfile
            sudo rm -f /swapfile
            
            # 从fstab中移除
            if grep -q "/swapfile" /etc/fstab; then
                sudo sed -i '/swapfile/d' /etc/fstab
                print_success "已从 /etc/fstab 移除 swap 配置"
            fi
            
            # 移除swappiness配置
            if grep -q "vm.swappiness" /etc/sysctl.conf; then
                sudo sed -i '/vm.swappiness/d' /etc/sysctl.conf
                print_info "已从 /etc/sysctl.conf 移除 swappiness 配置"
            fi
            
            print_success "Swap 已完全移除"
        else
            print_info "保留 Swap 配置"
        fi
    else
        print_info "未找到活跃的 Swap 配置"
    fi
}

# 清理残留文件
cleanup_files() {
    
    print_info "正在清理残留文件..."
    
    # Python版本（uv管理的）
    UV_PYTHON_DIR="$HOME/.local/share/uv/python"
    if [ -d "$UV_PYTHON_DIR" ]; then
        read -p "是否删除 uv 管理的 Python 版本？ (y/n): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$UV_PYTHON_DIR"
            print_success "已删除 uv Python 版本"
        fi
    fi
    
    # Kimi配置文件
    if [ -d "$HOME/.kimi" ]; then
        read -p "是否删除 Kimi CLI 配置文件 (~/.kimi)？ (y/n): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$HOME/.kimi"
            print_success "Kimi 配置文件已删除"
        fi
    fi
}

# 主函数
main() {
    echo "请选择卸载选项："
    echo ""
    echo "1) 仅卸载 Kimi CLI"
    echo "2) 卸载 Kimi CLI + uv"
    echo "3) 卸载 Kimi CLI + remove Swap"
    echo "4) 完全卸载（所有组件）"
    echo "5) 自定义卸载"
    echo "q) 退出"
    echo ""
    
    read -p "请选择 [1-5/q]: " choice
    
    case $choice in
        1)
            uninstall_kimi
            ;;
        2)
            uninstall_kimi
            uninstall_uv
            ;;
        3)
            uninstall_kimi
            uninstall_swap
            ;;
        4)
            uninstall_kimi
            uninstall_uv
            uninstall_swap
            cleanup_files
            ;;
        5)
            echo ""
            echo "自定义卸载选项："
            read -p "卸载 Kimi CLI? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then uninstall_kimi; fi

read -p "卸载 uv 包管理器? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then uninstall_uv; fi

read -p "卸载 Swap? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then uninstall_swap; fi

read -p "清理残留文件? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then cleanup_files; fi
            ;;
        q|Q)
            echo "退出卸载程序"
            exit 0
            ;;
        *)
            print_error "无效选项"
            exit 1
            ;;
    esac
    
    echo ""
    echo "========================================"
    print_success "卸载完成！"
    echo "========================================"
    echo ""
    
    # 显示卸载后的状态
    echo "当前状态:"
    echo "---------"
    
    if command -v kimi &> /dev/null; then
        echo -e "  Kimi CLI: ${RED}已安装${NC} ($(kimi --version))"
    else
        echo -e "  Kimi CLI: ${GREEN}未安装${NC}"
    fi
    
    if command -v uv &> /dev/null; then
        echo -e "  uv: ${RED}已安装${NC} ($(uv --version))"
    else
        echo -e "  uv: ${GREEN}未安装${NC}"
    fi
    
    if swapon --show | grep -q swapfile; then
        SWAP_SIZE=$(swapon --show --noheadings -o SIZE | head -1)
        echo -e "  Swap: ${RED}已启用${NC} ($SWAP_SIZE)"
    else
        echo -e "  Swap: ${GREEN}未启用${NC}"
    fi
    
    echo ""
}

# 运行主函数
main "$@"
