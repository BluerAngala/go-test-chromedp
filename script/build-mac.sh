#!/bin/bash

# Mac 平台构建脚本
# 使用方法: ./script/build-mac.sh [选项]
# 选项:
#   --clean    清理旧的构建文件
#   --release  构建发布版本（默认）
#   --dev      构建开发版本

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查是否在 macOS 上
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}错误: 此脚本只能在 macOS 系统上运行${NC}"
    echo "Mac 应用必须在 macOS 系统上构建"
    exit 1
fi

# 检查 wails 是否安装
if ! command -v wails &> /dev/null; then
    echo -e "${RED}错误: 未找到 wails 命令${NC}"
    echo "请先安装 Wails: go install github.com/wailsapp/wails/v2/cmd/wails@latest"
    exit 1
fi

# 解析参数
CLEAN=false
BUILD_TYPE="release"

while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            CLEAN=true
            shift
            ;;
        --dev)
            BUILD_TYPE="dev"
            shift
            ;;
        --release)
            BUILD_TYPE="release"
            shift
            ;;
        *)
            echo -e "${YELLOW}未知参数: $1${NC}"
            shift
            ;;
    esac
done

echo -e "${GREEN}开始构建 Mac 应用...${NC}"

# 清理旧的构建文件
if [ "$CLEAN" = true ]; then
    echo -e "${YELLOW}清理旧的构建文件...${NC}"
    rm -rf build/bin/*
    rm -rf frontend/dist
fi

# 构建前端
echo -e "${GREEN}构建前端资源...${NC}"
cd frontend
npm install
npm run build
cd ..

# 构建应用
echo -e "${GREEN}构建 Mac 应用...${NC}"
if [ "$BUILD_TYPE" = "dev" ]; then
    wails build -dev
else
    wails build
fi

# 检查构建结果
if [ -f "build/bin/test-chromedp.app" ] || [ -f "build/bin/test-chromedp" ]; then
    echo -e "${GREEN}✓ 构建成功！${NC}"
    echo -e "${GREEN}应用位置: build/bin/${NC}"
    
    # 显示应用信息
    if [ -f "build/bin/test-chromedp.app" ]; then
        echo -e "${GREEN}应用包: build/bin/test-chromedp.app${NC}"
        # 获取应用大小
        SIZE=$(du -sh "build/bin/test-chromedp.app" | cut -f1)
        echo -e "${GREEN}应用大小: $SIZE${NC}"
    fi
else
    echo -e "${RED}✗ 构建失败，请检查错误信息${NC}"
    exit 1
fi

echo -e "${GREEN}完成！${NC}"

