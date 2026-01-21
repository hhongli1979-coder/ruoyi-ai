#!/bin/bash
###############################################################################
# RuoYi AI - RunPod 一键部署
# 运行此脚本，然后在 RunPod 上创建 Endpoint 即可
###############################################################################

set -e

echo "🚀 RuoYi AI - RunPod 一键部署"
echo ""

# 获取 Docker Hub 用户名
read -p "Docker Hub 用户名: " DOCKER_USER
if [ -z "$DOCKER_USER" ]; then
    echo "❌ 用户名不能为空"
    exit 1
fi

IMAGE_NAME="${DOCKER_USER}/ruoyi-ai:latest"

echo ""
echo "📦 开始构建和推送镜像: $IMAGE_NAME"
echo ""

# 登录 Docker Hub
echo "🔐 登录 Docker Hub..."
docker login

# 构建镜像
echo ""
echo "🏗️ 构建镜像（这需要几分钟）..."
docker build --no-cache -t "$IMAGE_NAME" .

# 推送镜像
echo ""
echo "📤 推送镜像到 Docker Hub..."
docker push "$IMAGE_NAME"

# 显示部署说明
echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ 镜像已准备好！"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "📝 下一步：在 RunPod 创建 Endpoint"
echo ""
echo "1. 访问: https://www.runpod.io/console/serverless"
echo ""
echo "2. 点击 'New Endpoint' 并填写："
echo "   - Name: ruoyi-ai"
echo "   - Container Image: $IMAGE_NAME"
echo "   - Container Disk: 30 GB"
echo "   - GPU: RTX 4090 或 A100"
echo ""
echo "3. 添加环境变量（必需）："
echo "   MYSQL_HOST=你的MySQL地址"
echo "   MYSQL_USER=数据库用户名"
echo "   MYSQL_PASSWORD=数据库密码"
echo "   MYSQL_DATABASE=ruoyi-ai"
echo "   REDIS_HOST=你的Redis地址"
echo ""
echo "4. 点击 'Deploy' 完成！"
echo ""
echo "════════════════════════════════════════════════════════════"
echo "🎉 部署完成！"
