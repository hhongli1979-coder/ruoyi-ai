#!/bin/bash
###############################################################################
# RuoYi AI - RunPod 完整项目部署脚本
# RuoYi AI - RunPod Full Stack Deployment Script
# 
# 部署说明 / Deployment Info:
# 此脚本用于部署完整的 RuoYi AI 项目，包括：
# This script deploys the complete RuoYi AI project, including:
# 1. 后端服务 (ruoyi-ai) - Backend API Service
# 2. 管理后台 (ruoyi-admin) - Admin Frontend
# 3. 用户前端 (ruoyi-web) - User Frontend (Optional)
###############################################################################

set -e

# 颜色输出 / Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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
    echo -e "${CYAN}=============================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}=============================================${NC}"
    echo ""
}

# 检查命令是否存在 / Check if command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "$1 未安装，请先安装 / $1 is not installed, please install it first"
        exit 1
    fi
}

# 清理临时目录函数 / Cleanup function
cleanup() {
    if [ -d "/tmp/ruoyi-admin-deploy" ]; then
        print_info "清理临时目录... / Cleaning up temporary directories..."
        rm -rf /tmp/ruoyi-admin-deploy
    fi
    if [ -d "/tmp/ruoyi-web-deploy" ]; then
        rm -rf /tmp/ruoyi-web-deploy
    fi
}

# 注册清理函数 / Register cleanup on exit
trap cleanup EXIT

# 主脚本开始 / Main script starts
print_header "RuoYi AI - RunPod 完整项目部署助手 / Full Stack Deployment Helper"

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

# 询问要部署哪些组件 / Ask which components to deploy
print_info "请选择要部署的组件 / Please select components to deploy:"
echo ""
echo "1) 仅后端 API / Backend API only"
echo "2) 后端 + 管理后台 / Backend + Admin Frontend"
echo "3) 完整项目 (后端 + 管理后台 + 用户前端) / Full Stack (Backend + Admin + User Frontend)"
echo ""
read -p "请选择 (1-3) / Select (1-3): " DEPLOY_OPTION

case $DEPLOY_OPTION in
    1)
        DEPLOY_BACKEND=true
        DEPLOY_ADMIN=false
        DEPLOY_WEB=false
        ;;
    2)
        DEPLOY_BACKEND=true
        DEPLOY_ADMIN=true
        DEPLOY_WEB=false
        ;;
    3)
        DEPLOY_BACKEND=true
        DEPLOY_ADMIN=true
        DEPLOY_WEB=true
        ;;
    *)
        print_error "无效的选项 / Invalid option"
        exit 1
        ;;
esac

# 询问是否登录 Docker Hub / Ask if need to login to Docker Hub
read -p "是否需要登录 Docker Hub? (y/n) / Need to login to Docker Hub? (y/n): " LOGIN_DOCKER
if [[ "$LOGIN_DOCKER" =~ ^[Yy]$ ]]; then
    print_info "登录 Docker Hub... / Logging in to Docker Hub..."
    docker login
fi

# 部署后端 / Deploy backend
if [ "$DEPLOY_BACKEND" = true ]; then
    print_header "构建后端 Docker 镜像 / Building Backend Docker Image"
    
    BACKEND_IMAGE="${DOCKER_USERNAME}/ruoyi-ai-backend:${IMAGE_TAG}"
    print_info "镜像名称 / Image name: ${BACKEND_IMAGE}"
    print_info "这可能需要几分钟时间... / This may take a few minutes..."
    
    if docker build -t "$BACKEND_IMAGE" .; then
        print_success "后端镜像构建成功 / Backend image built successfully"
        
        read -p "是否推送后端镜像到 Docker Hub? (y/n) / Push backend image to Docker Hub? (y/n): " PUSH_BACKEND
        if [[ "$PUSH_BACKEND" =~ ^[Yy]$ ]]; then
            if docker push "$BACKEND_IMAGE"; then
                print_success "后端镜像推送成功 / Backend image pushed successfully"
            else
                print_error "后端镜像推送失败 / Backend image push failed"
                exit 1
            fi
        fi
    else
        print_error "后端镜像构建失败 / Backend image build failed"
        exit 1
    fi
fi

# 部署管理后台 / Deploy admin frontend
if [ "$DEPLOY_ADMIN" = true ]; then
    print_header "准备管理后台部署 / Preparing Admin Frontend Deployment"
    
    ADMIN_REPO_URL="https://github.com/hhongli1979-coder/ruoyi-admin.git"
    ADMIN_DIR="/tmp/ruoyi-admin-deploy"
    
    print_info "克隆管理后台仓库... / Cloning admin repository..."
    
    if [ -d "$ADMIN_DIR" ]; then
        rm -rf "$ADMIN_DIR"
    fi
    
    if git clone --depth 1 "$ADMIN_REPO_URL" "$ADMIN_DIR"; then
        print_success "管理后台仓库克隆成功 / Admin repository cloned successfully"
        
        print_info "构建管理后台镜像... / Building admin image..."
        ADMIN_IMAGE="${DOCKER_USERNAME}/ruoyi-ai-admin:${IMAGE_TAG}"
        
        cd "$ADMIN_DIR"
        if docker build -f scripts/deploy/Dockerfile -t "$ADMIN_IMAGE" .; then
            print_success "管理后台镜像构建成功 / Admin image built successfully"
            
            read -p "是否推送管理后台镜像到 Docker Hub? (y/n) / Push admin image to Docker Hub? (y/n): " PUSH_ADMIN
            if [[ "$PUSH_ADMIN" =~ ^[Yy]$ ]]; then
                if docker push "$ADMIN_IMAGE"; then
                    print_success "管理后台镜像推送成功 / Admin image pushed successfully"
                else
                    print_error "管理后台镜像推送失败 / Admin image push failed"
                fi
            fi
        else
            print_error "管理后台镜像构建失败 / Admin image build failed"
            ADMIN_IMAGE="" # 确保变量为空
        fi
        
        cd "$PROJECT_ROOT"
    else
        print_error "管理后台仓库克隆失败 / Admin repository clone failed"
        ADMIN_IMAGE="" # 确保变量为空
    fi
fi

# 部署用户前端 / Deploy user frontend
if [ "$DEPLOY_WEB" = true ]; then
    print_header "准备用户前端部署 / Preparing User Frontend Deployment"
    
    WEB_REPO_URL="https://github.com/ageerle/ruoyi-web.git"
    WEB_DIR="/tmp/ruoyi-web-deploy"
    
    print_info "克隆用户前端仓库... / Cloning web repository..."
    
    if [ -d "$WEB_DIR" ]; then
        rm -rf "$WEB_DIR"
    fi
    
    if git clone --depth 1 "$WEB_REPO_URL" "$WEB_DIR"; then
        print_success "用户前端仓库克隆成功 / Web repository cloned successfully"
        
        print_info "构建用户前端镜像... / Building web image..."
        WEB_IMAGE="${DOCKER_USERNAME}/ruoyi-ai-web:${IMAGE_TAG}"
        
        cd "$WEB_DIR"
        # 检查是否存在 Dockerfile / Check if Dockerfile exists
        if [ -f "Dockerfile" ] || [ -f "scripts/deploy/Dockerfile" ]; then
            DOCKERFILE_PATH="Dockerfile"
            if [ -f "scripts/deploy/Dockerfile" ]; then
                DOCKERFILE_PATH="scripts/deploy/Dockerfile"
            fi
            if docker build -f "$DOCKERFILE_PATH" -t "$WEB_IMAGE" .; then
                print_success "用户前端镜像构建成功 / Web image built successfully"
                
                read -p "是否推送用户前端镜像到 Docker Hub? (y/n) / Push web image to Docker Hub? (y/n): " PUSH_WEB
                if [[ "$PUSH_WEB" =~ ^[Yy]$ ]]; then
                    if docker push "$WEB_IMAGE"; then
                        print_success "用户前端镜像推送成功 / Web image pushed successfully"
                    else
                        print_error "用户前端镜像推送失败 / Web image push failed"
                    fi
                fi
            else
                print_error "用户前端镜像构建失败 / Web image build failed"
                WEB_IMAGE="" # 确保变量为空
            fi
        else
            print_warning "用户前端没有 Dockerfile，跳过构建 / No Dockerfile found in web repo, skipping"
            WEB_IMAGE="" # 确保变量为空
        fi
        
        cd "$PROJECT_ROOT"
    else
        print_error "用户前端仓库克隆失败 / Web repository clone failed"
    fi
fi

# 显示部署总结 / Show deployment summary
print_header "部署总结 / Deployment Summary"

echo ""
print_success "镜像准备完成！/ Images are ready!"
echo ""

if [ "$DEPLOY_BACKEND" = true ] && [ -n "$BACKEND_IMAGE" ]; then
    echo -e "${GREEN}✓${NC} 后端镜像 / Backend Image: ${BACKEND_IMAGE}"
fi

if [ "$DEPLOY_ADMIN" = true ] && [ -n "$ADMIN_IMAGE" ]; then
    echo -e "${GREEN}✓${NC} 管理后台镜像 / Admin Image: ${ADMIN_IMAGE}"
fi

if [ "$DEPLOY_WEB" = true ] && [ -n "$WEB_IMAGE" ]; then
    echo -e "${GREEN}✓${NC} 用户前端镜像 / Web Image: ${WEB_IMAGE}"
fi

echo ""

# 显示下一步操作 / Show next steps
print_header "部署到 RunPod / Deploy to RunPod"

cat << EOF
${YELLOW}下一步操作 / Next steps:${NC}

${CYAN}方案 1: 分别部署 (推荐用于独立扩展) / Option 1: Deploy Separately (Recommended for independent scaling)${NC}

为每个组件在 RunPod 创建独立的 Serverless Endpoint：

EOF

if [ -n "$BACKEND_IMAGE" ]; then
cat << EOF
${BLUE}1. 后端 API Endpoint / Backend API Endpoint${NC}
   访问 / Visit: https://www.runpod.io/console/serverless
   - Container Image: ${BACKEND_IMAGE}
   - 环境变量 / Environment Variables:
     MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE
     REDIS_HOST, REDIS_PORT (可选 / optional)
     SERVER_PORT=8080

EOF
fi

if [ -n "$ADMIN_IMAGE" ]; then
cat << EOF
${BLUE}2. 管理后台 Endpoint / Admin Frontend Endpoint${NC}
   访问 / Visit: https://www.runpod.io/console/serverless
   - Container Image: ${ADMIN_IMAGE}
   - 环境变量 / Environment Variables:
     VITE_API_URL=<后端API地址 / Backend API URL>

EOF
fi

if [ -n "$WEB_IMAGE" ]; then
cat << EOF
${BLUE}3. 用户前端 Endpoint / User Frontend Endpoint${NC}
   访问 / Visit: https://www.runpod.io/console/serverless
   - Container Image: ${WEB_IMAGE}
   - 环境变量 / Environment Variables:
     VITE_API_URL=<后端API地址 / Backend API URL>

EOF
fi

cat << EOF

${CYAN}方案 2: 统一部署 (开发/测试环境) / Option 2: Unified Deployment (Dev/Test)${NC}

如需在单个容器中部署所有组件，请参考文档：
For deploying all components in a single container, see documentation:
${PROJECT_ROOT}/docs/RunPod完整部署指南.md

${GREEN}更多信息请参考 / For more information, see:${NC}
- RunPod 部署指南 / RunPod Deployment Guide: .runpod/README.md
- 快速开始 / Quick Start: docs/RunPod快速部署指南.md
- 官方文档 / Official Documentation: https://doc.pandarobot.chat

${GREEN}部署完成! / Deployment ready!${NC}
EOF
