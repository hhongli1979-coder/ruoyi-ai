# RuoYi AI Copilot - Docker 部署完整指南

[English](DOCKER_GUIDE_EN.md) | 中文

本指南详细介绍如何使用 Docker 部署 RuoYi AI Copilot。

## 📋 目录

- [前置要求](#前置要求)
- [快速开始](#快速开始)
- [配置说明](#配置说明)
- [部署方式](#部署方式)
- [运维管理](#运维管理)
- [故障排查](#故障排查)
- [高级配置](#高级配置)

## 🔧 前置要求

### 必需软件

- **Docker**: 20.10.0 或更高版本
- **Docker Compose**: 2.0.0 或更高版本（可选，推荐）

### 安装 Docker

#### Linux (Ubuntu/Debian)
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

#### macOS
```bash
# 使用 Homebrew
brew install --cask docker

# 或下载 Docker Desktop
# https://www.docker.com/products/docker-desktop
```

#### Windows
下载并安装 [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)

### 验证安装
```bash
docker --version
docker-compose --version
```

## 🚀 快速开始

### 方法一：使用快速启动脚本（最简单）

1. **配置环境变量**
```bash
# 复制环境变量示例文件
cp .env.example .env

# 编辑 .env 文件，配置您的 API Key
nano .env
# 或
vim .env
```

2. **启动服务**
```bash
# 给脚本添加执行权限
chmod +x docker-start.sh

# 启动服务
./docker-start.sh start
```

3. **访问应用**
打开浏览器访问: http://localhost:8080

### 方法二：使用 Docker Compose

1. **配置环境变量**
```bash
cp .env.example .env
# 编辑 .env 文件
nano .env
```

2. **启动服务**
```bash
docker-compose up -d
```

3. **查看日志**
```bash
docker-compose logs -f
```

### 方法三：使用 Docker 命令

```bash
docker run -d \
  --name ruoyi-ai-copilot \
  -p 8080:8080 \
  -e SPRING_AI_OPENAI_API_KEY=your-api-key \
  -v $(pwd)/workspace:/app/workspace \
  -v $(pwd)/logs:/app/logs \
  ruoyi-ai-copilot:latest
```

## ⚙️ 配置说明

### 环境变量

在 `.env` 文件中配置以下变量：

```bash
# ==========================================
# Spring AI 配置（必需）
# ==========================================
SPRING_AI_OPENAI_API_KEY=sk-your-api-key-here

# API 基础 URL（可选）
# 阿里云通义千问（默认）
SPRING_AI_OPENAI_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode
# 或使用 OpenAI
# SPRING_AI_OPENAI_BASE_URL=https://api.openai.com/v1

# 模型选择（可选）
# 阿里云: qwen-plus, qwen-turbo, qwen-max
# OpenAI: gpt-4, gpt-3.5-turbo
SPRING_AI_OPENAI_CHAT_OPTIONS_MODEL=qwen-plus

# ==========================================
# 服务器配置（可选）
# ==========================================
SERVER_PORT=8080

# ==========================================
# 安全配置（可选）
# ==========================================
# DEFAULT: 需要用户确认
# AUTO_EDIT: 自动编辑模式
# YOLO: 完全自动模式（不推荐）
APP_SECURITY_APPROVAL_MODE=DEFAULT

# ==========================================
# 日志配置（可选）
# ==========================================
LOGGING_LEVEL_ROOT=INFO
LOGGING_LEVEL_COM_EXAMPLE_DEMO=DEBUG
```

### 获取 API Key

#### 阿里云通义千问（推荐）
1. 访问 [阿里云百炼平台](https://bailian.console.aliyun.com/)
2. 创建应用并获取 API Key
3. 复制 API Key 到 `.env` 文件

#### OpenAI
1. 访问 [OpenAI Platform](https://platform.openai.com/)
2. 创建 API Key
3. 修改 `.env` 文件中的 BASE_URL 和 API_KEY

## 🏗️ 部署方式

### 1. 本地构建镜像

```bash
# 使用构建脚本
chmod +x docker-build.sh
./docker-build.sh

# 或手动构建
docker build -t ruoyi-ai-copilot:latest .
```

### 2. 推送到 Docker Hub

```bash
# 使用构建脚本推送
./docker-build.sh -u your-username -p

# 或手动推送
docker tag ruoyi-ai-copilot:latest your-username/ruoyi-ai-copilot:latest
docker push your-username/ruoyi-ai-copilot:latest
```

### 3. 推送到阿里云容器镜像服务

```bash
# 登录阿里云
docker login --username=your-username registry.cn-hangzhou.aliyuncs.com

# 使用构建脚本
./docker-build.sh \
  -r registry.cn-hangzhou.aliyuncs.com \
  -u your-namespace \
  -p

# 或手动推送
docker tag ruoyi-ai-copilot:latest \
  registry.cn-hangzhou.aliyuncs.com/your-namespace/ruoyi-ai-copilot:latest
docker push registry.cn-hangzhou.aliyuncs.com/your-namespace/ruoyi-ai-copilot:latest
```

### 4. 生产环境部署

```bash
# 使用 docker-compose 生产配置
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## 🔨 运维管理

### 常用命令

```bash
# 使用快速启动脚本
./docker-start.sh start      # 启动服务
./docker-start.sh stop       # 停止服务
./docker-start.sh restart    # 重启服务
./docker-start.sh logs       # 查看日志
./docker-start.sh status     # 查看状态
./docker-start.sh build      # 重新构建
./docker-start.sh clean      # 清理

# 或使用 docker-compose
docker-compose up -d         # 启动
docker-compose down          # 停止
docker-compose restart       # 重启
docker-compose logs -f       # 查看日志
docker-compose ps            # 查看状态
```

### 查看日志

```bash
# 实时查看所有日志
docker-compose logs -f

# 查看最近 100 行日志
docker-compose logs --tail=100

# 只查看错误日志
docker-compose logs | grep ERROR
```

### 进入容器

```bash
# 进入容器 bash
docker exec -it ruoyi-ai-copilot bash

# 或使用 sh (Alpine Linux)
docker exec -it ruoyi-ai-copilot sh
```

### 备份数据

```bash
# 备份工作目录
tar -czf workspace-backup-$(date +%Y%m%d).tar.gz workspace/

# 备份日志
tar -czf logs-backup-$(date +%Y%m%d).tar.gz logs/
```

### 更新镜像

```bash
# 拉取最新镜像
docker-compose pull

# 重启服务
docker-compose up -d
```

## 🐛 故障排查

### 问题 1: 容器启动失败

**症状**: `docker-compose up` 失败

**解决方案**:
```bash
# 查看详细日志
docker-compose logs

# 检查环境变量
cat .env

# 检查端口占用
lsof -i :8080
# 或
netstat -tulpn | grep 8080
```

### 问题 2: API Key 无效

**症状**: 日志显示 "Invalid API Key" 或 401 错误

**解决方案**:
1. 检查 `.env` 文件中的 `SPRING_AI_OPENAI_API_KEY`
2. 确认 API Key 有效且有足够额度
3. 检查 `SPRING_AI_OPENAI_BASE_URL` 是否正确

### 问题 3: 容器内存不足

**症状**: 容器频繁重启，日志显示 OOM

**解决方案**:
```yaml
# 在 docker-compose.yml 中增加内存限制
services:
  ruoyi-ai-copilot:
    environment:
      - JAVA_OPTS=-Xms1g -Xmx2g
    deploy:
      resources:
        limits:
          memory: 3G
```

### 问题 4: 工作目录权限问题

**症状**: 无法读写 workspace 目录

**解决方案**:
```bash
# 修改目录权限
chmod -R 755 workspace/
chown -R $USER:$USER workspace/
```

### 问题 5: 健康检查失败

**症状**: 容器状态显示 unhealthy

**解决方案**:
```bash
# 检查健康检查端点
curl http://localhost:8080/actuator/health

# 查看详细日志
docker inspect ruoyi-ai-copilot | grep Health -A 10
```

## 🔐 高级配置

### 1. 使用自定义配置文件

```bash
# 挂载自定义 application.yml
docker run -d \
  -v $(pwd)/application.yml:/app/config/application.yml \
  ruoyi-ai-copilot:latest
```

### 2. 配置反向代理（Nginx）

```nginx
upstream copilot {
    server localhost:8080;
}

server {
    listen 80;
    server_name copilot.example.com;

    location / {
        proxy_pass http://copilot;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # SSE 配置
        proxy_set_header Connection '';
        proxy_http_version 1.1;
        chunked_transfer_encoding off;
        proxy_buffering off;
        proxy_cache off;
    }
}
```

### 3. 使用 HTTPS

```yaml
# docker-compose.yml
services:
  ruoyi-ai-copilot:
    environment:
      - SERVER_SSL_ENABLED=true
      - SERVER_SSL_KEY_STORE=/app/ssl/keystore.p12
      - SERVER_SSL_KEY_STORE_PASSWORD=your-password
    volumes:
      - ./ssl:/app/ssl
```

### 4. 集群部署

```yaml
# docker-compose.yml
services:
  ruoyi-ai-copilot:
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure
      resources:
        limits:
          cpus: '2'
          memory: 2G
```

### 5. 监控配置

```yaml
# docker-compose.yml
services:
  ruoyi-ai-copilot:
    environment:
      - MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info,metrics,prometheus
      - MANAGEMENT_METRICS_EXPORT_PROMETHEUS_ENABLED=true
```

## 📊 性能优化

### JVM 参数优化

```bash
# 在 .env 中配置
JAVA_OPTS=-Xms1g -Xmx2g -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UseStringDeduplication
```

### Docker 资源限制

```yaml
deploy:
  resources:
    limits:
      cpus: '4'
      memory: 4G
    reservations:
      cpus: '1'
      memory: 1G
```

## 📚 相关文档

- [README.md](README.md) - 项目主文档
- [README_EN.md](README_EN.md) - 英文文档
- [pom.xml](pom.xml) - Maven 配置
- [application.yml](src/main/resources/application.yml) - 应用配置

## 🆘 获取帮助

遇到问题？

1. 查看 [常见问题](#故障排查)
2. 查看 Docker 日志: `docker-compose logs -f`
3. 提交 Issue: [GitHub Issues](https://github.com/hhongli1979-coder/ruoyi-ai/issues)

---

**祝您使用愉快！** 🎉
