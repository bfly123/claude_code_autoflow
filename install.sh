#!/bin/bash

# Claude Code 渐进式任务管理系统 - 安装脚本
# Version: 2.0

set -e

echo "========================================"
echo "Claude Code 渐进式任务管理系统"
echo "Installation Script v2.0"
echo "========================================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        CLAUDE_DIR="$HOME/.claude"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="mac"
        CLAUDE_DIR="$HOME/.claude"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        OS="windows"
        CLAUDE_DIR="$USERPROFILE/.claude"
    else
        echo -e "${RED}错误: 不支持的操作系统${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓${NC} 检测到操作系统: $OS"
}

# 检查 Claude Code
check_claude() {
    echo ""
    echo "检查 Claude Code..."

    if [ -d "$CLAUDE_DIR" ]; then
        echo -e "${GREEN}✓${NC} 找到 Claude Code 配置目录: $CLAUDE_DIR"
    else
        echo -e "${YELLOW}⚠${NC}  未找到 Claude Code 配置目录"
        echo "   是否创建? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            mkdir -p "$CLAUDE_DIR/commands"
            echo -e "${GREEN}✓${NC} 已创建配置目录"
        else
            echo -e "${RED}✗${NC} 安装已取消"
            exit 1
        fi
    fi
}

# 安装命令文件
install_commands() {
    echo ""
    echo "安装命令文件..."

    # 创建命令目录
    mkdir -p "$CLAUDE_DIR/commands"

    # 复制命令文件
    COMMANDS=("plan.md" "expand.md" "run.md" "progress.md")
    for cmd in "${COMMANDS[@]}"; do
        if [ -f "commands/$cmd" ]; then
            cp "commands/$cmd" "$CLAUDE_DIR/commands/"
            echo -e "${GREEN}✓${NC} 已安装: /$cmd"
        else
            echo -e "${RED}✗${NC} 文件不存在: commands/$cmd"
            exit 1
        fi
    done
}

# 安装全局配置（可选）
install_global_config() {
    echo ""
    echo "是否安装全局 CLAUDE.md 配置? (y/n)"
    echo "   这会将配置应用到所有项目"
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        if [ -f "CLAUDE.md.example" ]; then
            if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
                echo -e "${YELLOW}⚠${NC}  已存在 CLAUDE.md，是否覆盖? (y/n)"
                read -r overwrite
                if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
                    echo -e "${YELLOW}⚠${NC}  跳过全局配置安装"
                    return
                fi
            fi
            cp "CLAUDE.md.example" "$CLAUDE_DIR/CLAUDE.md"
            echo -e "${GREEN}✓${NC} 已安装全局配置"
        else
            echo -e "${YELLOW}⚠${NC}  未找到 CLAUDE.md.example"
        fi
    else
        echo -e "${YELLOW}⚠${NC}  跳过全局配置安装"
    fi
}

# 验证安装
verify_installation() {
    echo ""
    echo "验证安装..."

    ALL_INSTALLED=true
    COMMANDS=("plan.md" "expand.md" "run.md" "progress.md")

    for cmd in "${COMMANDS[@]}"; do
        if [ -f "$CLAUDE_DIR/commands/$cmd" ]; then
            echo -e "${GREEN}✓${NC} ${cmd%.md}"
        else
            echo -e "${RED}✗${NC} ${cmd%.md}"
            ALL_INSTALLED=false
        fi
    done

    if [ "$ALL_INSTALLED" = true ]; then
        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}✓ 安装成功！${NC}"
        echo -e "${GREEN}========================================${NC}"
        echo ""
        echo "可用命令:"
        echo "  /plan [任务描述]    - 创建规划"
        echo "  /expand             - 展开Complex步骤"
        echo "  /run [额外需求]     - 执行并审查"
        echo "  /progress           - 查看进度"
        echo ""
        echo "快速开始:"
        echo "  1. 在 Claude Code 中运行: /plan [你的任务]"
        echo "  2. 根据提示使用 /run 或 /expand"
        echo "  3. 记得每次 /run 后使用 /clear"
        echo ""
        echo "文档:"
        echo "  - README.md  - 完整使用说明"
        echo "  - PLAN.md    - 系统设计文档"
        echo ""
    else
        echo ""
        echo -e "${RED}✗ 安装未完成，请检查错误信息${NC}"
        exit 1
    fi
}

# 主流程
main() {
    detect_os
    check_claude
    install_commands
    install_global_config
    verify_installation
}

# 运行安装
main
