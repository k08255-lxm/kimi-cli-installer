#!/bin/bash

# Kimi CLI + Swap 安装验证脚本
# 用于验证安装是否成功

set -e

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "   Kimi CLI + Swap 安装验证"
echo "========================================"
echo ""

# 计数器
PASSED=0
FAILED=0

# 测试函数
test_command() {
    local cmd=$1
    local name=$2
    
    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $name 已安装"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $name 未找到"
        ((FAILED++))
        return 1
    fi
}

# 测试1: 检查uv
echo "测试 1/5: 检查 uv 包管理器"
if test_command "uv" "uv"; then
    echo "  版本: $(uv --version)"
fi
echo ""

# 测试2: 检查kimi
echo "测试 2/5: 检查 kimi CLI"
if test_command "kimi" "kimi"; then
    echo "  版本: $(kimi --version)"
fi
echo ""

# 测试3: 检查Python 3.13
echo "测试 3/5: 检查 Python 3.13"
if command -v python3.13 &> /dev/null; then
    echo -e "${GREEN}✓${NC} Python 3.13 已安装"
    echo "  版本: $(python3.13 --version)"
    ((PASSED++))
else
    echo -e "${YELLOW}!${NC} Python 3.13 未在PATH中（可能通过uv管理）"
    ((PASSED++))  # 这不一定是错误
fi
echo ""

# 测试4: 检查Swap
echo "测试 4/5: 检查 Swap 配置"
if swapon --show | grep -q "/swapfile"; then
    SWAP_SIZE=$(swapon --show --noheadings -o SIZE | head -1)
    echo -e "${GREEN}✓${NC} Swap 文件已启用"
    echo "  大小: $SWAP_SIZE"
    
    # 检查fstab配置
    if grep -q "/swapfile" /etc/fstab; then
        echo -e "${GREEN}✓${NC} Swap 已配置开机自动挂载"
    else
        echo -e "${YELLOW}!${NC} Swap 未配置开机自动挂载"
    fi
    ((PASSED++))
else
    echo -e "${YELLOW}!${NC} Swap 未配置（这是可选功能）"
    ((PASSED++))
fi
echo ""

# 测试5: 检查环境变量
echo "测试 5/5: 检查环境变量"
if echo "$PATH" | grep -q ".cargo/bin"; then
    echo -e "${GREEN}✓${NC} uv 路径已在 PATH 中"
    ((PASSED++))
else
    echo -e "${YELLOW}!${NC} uv 路径不在 PATH 中（可能需要重新加载 shell）"
    ((PASSED++))
fi
echo ""

# 总结
echo "========================================"
echo "验证结果:"
echo -e "  通过: ${GREEN}$PASSED${NC}"
echo -e "  失败: ${RED}$FAILED${NC}"
echo "========================================"
echo ""

# 详细环境信息
echo "详细环境信息:"
echo "-------------"
echo "Shell: $SHELL"
echo "OS: $(uname -a | head -1)"
echo ""
echo "PATH中包含的关键路径:"
echo "$PATH" | tr ':' '\n' | grep -E "cargo|kimi|python" || echo "  (无)"
echo ""
echo "已安装的Python版本:"
ls -1 ~/.local/share/uv/python/ 2>/dev/null || echo "  (uv python目录不存在或为空)"
echo ""

# 建议
if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}✓ 所有核心组件安装成功！${NC}"
    echo ""
    echo "下一步操作:"
    echo "1. 运行: kimi"
    echo "2. 发送: /setup"
    echo "3. 发送: /help 查看帮助"
    exit 0
else
    echo -e "${RED}✗ 部分组件安装失败${NC}"
    echo ""
    echo "建议:"
    echo "1. 重新运行安装脚本"
    echo "2. 检查网络连接"
    echo "3. 查看错误日志"
    exit 1
fi
