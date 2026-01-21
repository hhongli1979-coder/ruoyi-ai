#!/bin/bash
###############################################################################
# RuoYi AI - RunPod 快速部署脚本
# RuoYi AI - RunPod Quick Deployment Script
###############################################################################

set -e

# 颜色输出 / Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印函数 / Print functions
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

print_header() {
    echo ""
    echo "============================================="
    echo "$1"
    echo "============================================="
    echo ""
}

# 检查命令是否存在 / Check if command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "$1 未安装，请先安装 / $1 is not installed, please install it first"
        exit 1
    fi
}

# 主脚本开始 / Main script starts
print_header "RuoYi AI - RunPod 部署助手 / RunPod Deployment Helper"

# 检查必要的命令 / Check required commands
print_info "检查必要的工具... / Checking required tools..."
check_command "docker"
check_command "git"
print_success "所有必要工具已安装 / All required tools are installed"

# 获取项目根目录 / Get project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

print_info "项目目录 / Project directory: $PROJECT_ROOT"

# 交互式配置 / Interactive configuration
print_header "配置信息 / Configuration"

# Docker Hub 用户名 / Docker Hub username
read -p "请输入您的 Docker Hub 用户名 / Enter your Docker Hub username: " DOCKER_USERNAME
if [ -z "$DOCKER_USERNAME" ]; then
    print_error "用户名不能为空 / Username cannot be empty"
    exit 1
fi

# 镜像标签 / Image tag
read -p "请输入镜像标签 (默认: latest) / Enter image tag (default: latest): " IMAGE_TAG
IMAGE_TAG=${IMAGE_TAG:-latest}

# 完整的镜像名称 / Full image name
IMAGE_NAME="${DOCKER_USERNAME}/ruoyi-ai:${IMAGE_TAG}"

print_info "将构建镜像 / Will build image: ${IMAGE_NAME}"

# 询问是否登录 Docker Hub / Ask if need to login to Docker Hub
read -p "是否需要登录 Docker Hub? (y/n) / Need to login to Docker Hub? (y/n): " LOGIN_DOCKER
if [[ "$LOGIN_DOCKER" =~ ^[Yy]$ ]]; then
    print_info "登录 Docker Hub... / Logging in to Docker Hub..."
    docker login
fi

# 构建 Docker 镜像 / Build Docker image
print_header "构建 Docker 镜像 / Building Docker Image"
print_info "这可能需要几分钟时间... / This may take a few minutes..."

if docker build -t "$IMAGE_NAME" .; then
    print_success "Docker 镜像构建成功 / Docker image built successfully"
else
    print_error "Docker 镜像构建失败 / Docker image build failed"
    exit 1
fi

# 询问是否推送到 Docker Hub / Ask if need to push to Docker Hub
read -p "是否推送镜像到 Docker Hub? (y/n) / Push image to Docker Hub? (y/n): " PUSH_IMAGE
if [[ "$PUSH_IMAGE" =~ ^[Yy]$ ]]; then
    print_header "推送镜像到 Docker Hub / Pushing Image to Docker Hub"
    
    if docker push "$IMAGE_NAME"; then
        print_success "镜像推送成功 / Image pushed successfully"
    else
        print_error "镜像推送失败 / Image push failed"
        exit 1
    fi
fi

# 显示下一步操作 / Show next steps
print_header "部署到 RunPod / Deploy to RunPod"

cat << EOF
${GREEN}恭喜！镜像准备完成 / Congratulations! Image is ready${NC}

${BLUE}镜像名称 / Image name:${NC} ${IMAGE_NAME}

${YELLOW}下一步操作 / Next steps:${NC}

1. 登录 RunPod 控制台 / Login to RunPod Console
   https://www.runpod.io/console/serverless

2. 创建新的 Serverless Endpoint / Create new Serverless Endpoint
   - 点击 "New Endpoint" / Click "New Endpoint"
   - 填写名称：ruoyi-ai / Enter name: ruoyi-ai

3. 配置容器镜像 / Configure Container Image
   - Container Image: ${IMAGE_NAME}
   - Container Disk: 30 GB (推荐 / recommended)
   - GPU 类型 / GPU Type: RTX 4090 或 A100 / or A100

4. 配置必需的环境变量 / Configure required environment variables:
   ${BLUE}必需 / Required:${NC}
   - MYSQL_HOST=<你的MySQL主机 / your MySQL host>
   - MYSQL_USER=<你的MySQL用户名 / your MySQL username>
   - MYSQL_PASSWORD=<你的MySQL密码 / your MySQL password>
   - MYSQL_DATABASE=ruoyi-ai
   - REDIS_HOST=<你的Redis主机 / your Redis host>
   
   ${BLUE}可选 / Optional:${NC}
   - MYSQL_PORT=3306
   - REDIS_PORT=6379
   - REDIS_PASSWORD=<Redis密码 / Redis password>
   - OPENAI_API_KEY=<OpenAI密钥 / OpenAI key>
   - SERVER_PORT=8080
   - SPRING_PROFILES_ACTIVE=prod

5. 部署并测试 / Deploy and test
   - 点击 "Deploy" 部署 / Click "Deploy" to deploy
   - 等待容器启动 (约2-5分钟) / Wait for container to start (about 2-5 minutes)
   - 使用健康检查测试 / Test with health check:
     {
       "input": {
         "action": "health_check"
       }
     }

${GREEN}更多信息请参考 / For more information, see:${NC}
- RunPod 部署指南 / RunPod Deployment Guide: .runpod/README.md
- 官方文档 / Official Documentation: https://doc.pandarobot.chat

${GREEN}部署完成! / Deployment ready!${NC}
EOF
