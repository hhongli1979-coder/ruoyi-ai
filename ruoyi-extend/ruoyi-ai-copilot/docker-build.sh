#!/bin/bash
##############################################
# RuoYi AI Copilot Docker 构建脚本
# 功能：构建 Docker 镜像并推送到仓库
##############################################

set -euo pipefail

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 默认配置
IMAGE_NAME="ruoyi-ai-copilot"
VERSION="1.0.0"
REGISTRY=""
DOCKER_USERNAME=""

# 打印信息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    cat << EOF
RuoYi AI Copilot Docker 构建脚本

使用方法:
    ./docker-build.sh [选项]

选项:
    -n, --name NAME         镜像名称 (默认: ruoyi-ai-copilot)
    -v, --version VERSION   版本号 (默认: 1.0.0)
    -r, --registry REGISTRY Docker 仓库地址 (例如: docker.io, registry.cn-hangzhou.aliyuncs.com)
    -u, --username USERNAME Docker Hub 用户名
    -p, --push              构建后推送到仓库
    -h, --help              显示帮助信息

示例:
    # 本地构建
    ./docker-build.sh

    # 构建并推送到 Docker Hub
    ./docker-build.sh -u your-username -p

    # 构建并推送到阿里云容器镜像服务
    ./docker-build.sh -r registry.cn-hangzhou.aliyuncs.com -u your-namespace -p

EOF
}

# 解析参数
PUSH=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -r|--registry)
            REGISTRY="$2"
            shift 2
            ;;
        -u|--username)
            DOCKER_USERNAME="$2"
            shift 2
            ;;
        -p|--push)
            PUSH=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            print_error "未知参数: $1"
            show_help
            exit 1
            ;;
    esac
done

# 构建完整镜像名称
if [ -n "$REGISTRY" ]; then
    if [ -n "$DOCKER_USERNAME" ]; then
        FULL_IMAGE_NAME="${REGISTRY}/${DOCKER_USERNAME}/${IMAGE_NAME}"
    else
        FULL_IMAGE_NAME="${REGISTRY}/${IMAGE_NAME}"
    fi
else
    if [ -n "$DOCKER_USERNAME" ]; then
        FULL_IMAGE_NAME="${DOCKER_USERNAME}/${IMAGE_NAME}"
    else
        FULL_IMAGE_NAME="${IMAGE_NAME}"
    fi
fi

print_info "================================"
print_info "RuoYi AI Copilot Docker 构建"
print_info "================================"
print_info "镜像名称: ${FULL_IMAGE_NAME}"
print_info "版本号: ${VERSION}"
print_info "推送到仓库: ${PUSH}"
print_info "================================"

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    print_error "Docker 未安装，请先安装 Docker"
    exit 1
fi

# 构建镜像
print_info "开始构建 Docker 镜像..."
docker build -t "${FULL_IMAGE_NAME}:${VERSION}" \
             -t "${FULL_IMAGE_NAME}:latest" \
             -f Dockerfile .

if [ $? -eq 0 ]; then
    print_info "✅ Docker 镜像构建成功！"
    print_info "镜像: ${FULL_IMAGE_NAME}:${VERSION}"
    print_info "镜像: ${FULL_IMAGE_NAME}:latest"
else
    print_error "❌ Docker 镜像构建失败"
    exit 1
fi

# 推送镜像
if [ "$PUSH" = true ]; then
    print_info "开始推送镜像到仓库..."
    
    # 推送版本标签
    docker push "${FULL_IMAGE_NAME}:${VERSION}"
    if [ $? -eq 0 ]; then
        print_info "✅ 版本 ${VERSION} 推送成功"
    else
        print_error "❌ 版本 ${VERSION} 推送失败"
        exit 1
    fi
    
    # 推送 latest 标签
    docker push "${FULL_IMAGE_NAME}:latest"
    if [ $? -eq 0 ]; then
        print_info "✅ latest 标签推送成功"
    else
        print_error "❌ latest 标签推送失败"
        exit 1
    fi
    
    print_info "================================"
    print_info "✅ 所有镜像推送完成！"
    print_info "================================"
fi

# 显示镜像信息
print_info "镜像信息:"
docker images "${FULL_IMAGE_NAME}" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

print_info "================================"
print_info "✅ 构建流程完成！"
print_info "================================"
print_info "使用以下命令运行容器:"
print_info "docker run -d -p 8080:8080 -e SPRING_AI_OPENAI_API_KEY=your-key ${FULL_IMAGE_NAME}:latest"
print_info ""
print_info "或使用 docker-compose:"
print_info "docker-compose up -d"
