#!/bin/bash

# RuoYi-AI RunPod 一键部署脚本
# RunPod One-Click Deployment Script

set -e

echo "=================================================="
echo "   RuoYi-AI RunPod 一键部署"
echo "   RuoYi-AI RunPod One-Click Deployment"
echo "=================================================="
echo ""

# 提示输入 Docker Hub 用户名
read -p "Docker Hub 用户名 / Docker Hub Username: " DOCKER_USER
if [ -z "$DOCKER_USER" ]; then
    echo "❌ 用户名不能为空 / Username cannot be empty"
    exit 1
fi

IMAGE_NAME="${DOCKER_USER}/ruoyi-ai:latest"

echo ""
echo "📦 镜像名称 / Image Name: $IMAGE_NAME"
echo ""

# 询问是否需要登录
read -p "是否需要登录 Docker Hub? (Y/n) / Login to Docker Hub? (Y/n): " LOGIN_CHOICE
LOGIN_CHOICE=${LOGIN_CHOICE:-Y}

if [[ "$LOGIN_CHOICE" =~ ^[Yy]$ ]]; then
    echo "🔐 登录 Docker Hub / Logging in to Docker Hub..."
    docker login
fi

echo ""
echo "🏗️  开始构建镜像 / Building image..."
echo "⏱️  预计需要 5-10 分钟 / Estimated time: 5-10 minutes"
echo ""

# 构建镜像
if docker build --no-cache -t "$IMAGE_NAME" .; then
    echo ""
    echo "✅ 镜像构建成功 / Image built successfully"
else
    echo ""
    echo "❌ 镜像构建失败 / Image build failed"
    exit 1
fi

echo ""
echo "📤 推送镜像到 Docker Hub / Pushing image to Docker Hub..."
echo ""

# 推送镜像
if docker push "$IMAGE_NAME"; then
    echo ""
    echo "✅ 镜像推送成功 / Image pushed successfully"
else
    echo ""
    echo "❌ 镜像推送失败 / Image push failed"
    exit 1
fi

# 显示部署说明
cat << EOF

════════════════════════════════════════════════════════════
🎉 镜像已准备好！/ Image is Ready!
════════════════════════════════════════════════════════════

📝 下一步：在 RunPod 创建 Endpoint
   Next Step: Create Endpoint on RunPod

1. 访问 / Visit: https://www.runpod.io/console/serverless

2. 点击 'New Endpoint' 并配置 / Click 'New Endpoint' and configure:
   
   基本配置 / Basic Configuration:
   ├─ Name: ruoyi-ai
   ├─ Container Image: ${IMAGE_NAME}
   ├─ Container Disk: 30 GB
   └─ GPU Type: RTX 4090 或 A100 / or A100

3. 环境变量 / Environment Variables (必需 / Required):
   
   数据库配置 / Database:
   ├─ MYSQL_HOST=你的MySQL地址 / Your MySQL host
   ├─ MYSQL_PORT=3306
   ├─ MYSQL_USER=数据库用户名 / Database username
   ├─ MYSQL_PASSWORD=数据库密码 / Database password
   └─ MYSQL_DATABASE=ruoyi-ai
   
   Redis配置 / Redis:
   ├─ REDIS_HOST=你的Redis地址 / Your Redis host
   └─ REDIS_PORT=6379
   
   应用配置 / Application (可选 / Optional):
   ├─ SERVER_PORT=8080
   └─ SPRING_PROFILES_ACTIVE=prod

4. 点击 'Deploy' 完成部署 / Click 'Deploy' to finish!

5. 测试部署 / Test Deployment:
   
   发送测试请求 / Send test request:
   {
     "input": {
       "action": "health_check"
     }
   }
   
   预期响应 / Expected response:
   {
     "status": "healthy",
     "application": "RuoYi AI"
   }

════════════════════════════════════════════════════════════
📚 更多帮助 / More Help:
   
   - 完整文档 / Full Documentation:
     docs/RunPod完整部署指南.md
   
   - 快速指南 / Quick Guide:
     docs/RunPod快速部署指南.md
   
   - GitHub Issues:
     https://github.com/hhongli1979-coder/ruoyi-ai/issues

════════════════════════════════════════════════════════════

EOF
