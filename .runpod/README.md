# RuoYi AI - RunPod Serverless Deployment Guide

[![RunPod](https://api.runpod.io/badge/hhongli1979-coder/ruoyi-ai)](https://console.runpod.io/hub/hhongli1979-coder/ruoyi-ai)

[中文](#中文文档) | [English](#english-documentation)

---

## 中文文档

### 📖 概述

本指南将帮助您在 RunPod Serverless 平台上部署 RuoYi AI 企业级 AI 助手平台。RuoYi AI 集成了 FastGPT、Coze（扣子）、DIFY 等主流 AI 平台，提供 RAG（检索增强生成）、知识图谱、数字人等强大功能。

### 🎯 RunPod 平台简介

RunPod 是一个 GPU 云平台，专门为 AI/ML 工作负载设计。其 Serverless 功能允许您：
- 按需使用 GPU 资源，无需预付费用
- 自动扩展以处理不同的工作负载
- 只为实际使用的计算资源付费
- 快速部署容器化应用

### 🔧 部署前准备

在部署 RuoYi AI 到 RunPod 之前，请确保已准备好以下资源：

#### 1. 数据库服务

**MySQL 8.0+**
- 可以使用云数据库服务（如 AWS RDS、阿里云 RDS、腾讯云 CDB）
- 或自行搭建 MySQL 服务器
- 需要创建数据库：`ruoyi-ai`
- 导入初始化 SQL 脚本（位于项目 `sql/` 目录）

```sql
CREATE DATABASE `ruoyi-ai` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### 2. Redis 服务

- Redis 5.0+ 版本
- 可以使用云 Redis 服务（如 AWS ElastiCache、阿里云 Redis）
- 或自行搭建 Redis 服务器
- 建议启用持久化以防止数据丢失

#### 3. RunPod 账号

- 注册 RunPod 账号：https://www.runpod.io/
- 充值账户余额（建议至少 $10 用于测试）
- 获取 API 密钥（可选，用于 API 调用）

#### 4. 外部服务 API 密钥（可选）

根据您需要使用的功能，准备相应的 API 密钥：
- OpenAI API Key（用于 GPT 功能）
- FastGPT API Key（如果使用 FastGPT）
- Coze API Key（如果使用扣子平台）
- DIFY API Key（如果使用 DIFY）

### 📝 详细部署步骤

#### 步骤 1：构建 Docker 镜像

1. **克隆项目仓库**
```bash
git clone https://github.com/hhongli1979-coder/ruoyi-ai.git
cd ruoyi-ai
```

2. **构建 Docker 镜像**
```bash
docker build -t your-dockerhub-username/ruoyi-ai:latest .
```

3. **推送镜像到 Docker Hub**
```bash
docker login
docker push your-dockerhub-username/ruoyi-ai:latest
```

> **注意**: 您也可以使用其他容器镜像仓库，如 GitHub Container Registry 或私有镜像仓库。

#### 步骤 2：在 RunPod 上创建 Serverless Endpoint

1. **登录 RunPod 控制台**
   - 访问 https://www.runpod.io/console/serverless

2. **创建新的 Serverless Endpoint**
   - 点击 "New Endpoint" 按钮
   - 填写 Endpoint 名称：`ruoyi-ai`

3. **配置容器镜像**
   - Container Image: `your-dockerhub-username/ruoyi-ai:latest`
   - Container Disk: 30 GB（推荐）
   - GPU 类型：选择适合的 GPU（推荐 RTX 4090 或 A100）

4. **配置环境变量**

必需的环境变量：
```
MYSQL_HOST=your-mysql-host.com
MYSQL_PORT=3306
MYSQL_DATABASE=ruoyi-ai
MYSQL_USER=your-mysql-user
MYSQL_PASSWORD=your-mysql-password
REDIS_HOST=your-redis-host.com
REDIS_PORT=6379
```

可选的环境变量：
```
REDIS_PASSWORD=your-redis-password
OPENAI_API_KEY=sk-xxxxxxxxxxxx
SERVER_PORT=8080
SPRING_PROFILES_ACTIVE=prod
```

#### 步骤 3：部署和测试

1. **部署 Endpoint**
   - 检查所有配置无误后，点击 "Deploy" 按钮
   - 等待容器启动（首次启动可能需要 2-5 分钟）

2. **查看部署状态**
   - 在 RunPod 控制台中查看 Endpoint 状态
   - 检查日志输出，确认应用启动成功
   - 寻找日志中的 "RuoYiAI启动成功" 消息

3. **健康检查测试**

使用 RunPod API 或 Web 界面发送测试请求：

```json
{
  "input": {
    "action": "health_check"
  }
}
```

预期响应：
```json
{
  "status": "healthy",
  "application": "RuoYi AI",
  "details": {
    "status": "UP"
  }
}
```

### 🎮 API 使用示例

#### 1. 健康检查

**请求**:
```json
{
  "input": {
    "action": "health_check"
  }
}
```

**响应**:
```json
{
  "status": "healthy",
  "application": "RuoYi AI",
  "details": {...}
}
```

#### 2. 服务状态查询

**请求**:
```json
{
  "input": {
    "action": "status"
  }
}
```

**响应**:
```json
{
  "status": "running",
  "health": {...},
  "server_url": "http://localhost:8080",
  "timestamp": 1642584000.0
}
```

#### 3. AI 对话接口

**请求**:
```json
{
  "input": {
    "action": "chat",
    "message": "你好，请介绍一下 RuoYi AI 平台"
  }
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "message": "RuoYi AI 是一个...",
    "timestamp": "2024-01-20T10:30:00Z"
  }
}
```

### 🔍 环境变量详细说明

| 变量名 | 说明 | 默认值 | 必需 |
|--------|------|--------|------|
| `MYSQL_HOST` | MySQL 数据库主机地址 | - | ✅ |
| `MYSQL_PORT` | MySQL 数据库端口 | 3306 | ❌ |
| `MYSQL_DATABASE` | 数据库名称 | ruoyi-ai | ❌ |
| `MYSQL_USER` | 数据库用户名 | - | ✅ |
| `MYSQL_PASSWORD` | 数据库密码 | - | ✅ |
| `REDIS_HOST` | Redis 服务器地址 | - | ✅ |
| `REDIS_PORT` | Redis 服务器端口 | 6379 | ❌ |
| `REDIS_PASSWORD` | Redis 密码 | "" | ❌ |
| `OPENAI_API_KEY` | OpenAI API 密钥 | "" | ❌ |
| `SERVER_PORT` | 应用服务端口 | 8080 | ❌ |
| `SPRING_PROFILES_ACTIVE` | Spring Boot 配置文件 | prod | ❌ |

### ⚠️ 常见问题排查

#### 问题 1: 容器启动失败

**症状**: 容器启动后立即退出

**可能原因和解决方案**:
1. 检查环境变量是否正确配置
2. 验证数据库连接信息
3. 查看容器日志获取详细错误信息
4. 确保 MySQL 数据库已创建并导入初始化脚本

#### 问题 2: 数据库连接失败

**症状**: 日志显示 "Unable to connect to database"

**解决方案**:
1. 确认数据库主机地址可以从 RunPod 访问
2. 检查数据库用户名和密码是否正确
3. 验证数据库防火墙规则，允许来自 RunPod 的连接
4. 测试数据库连接：
```bash
mysql -h MYSQL_HOST -u MYSQL_USER -p
```

#### 问题 3: Redis 连接失败

**症状**: 日志显示 Redis 相关错误

**解决方案**:
1. 验证 Redis 服务器地址和端口
2. 如果 Redis 设置了密码，确保 `REDIS_PASSWORD` 正确配置
3. 检查 Redis 防火墙规则
4. 测试 Redis 连接：
```bash
redis-cli -h REDIS_HOST -p REDIS_PORT -a REDIS_PASSWORD
```

#### 问题 4: 应用启动慢

**症状**: 应用需要很长时间才能准备就绪

**解决方案**:
1. 这是正常现象，Java 应用启动通常需要 30-120 秒
2. 可以在 Dockerfile 中调整 JVM 参数以优化启动时间
3. 使用更快的存储类型（如 NVMe SSD）
4. 检查数据库和 Redis 的响应速度

#### 问题 5: 健康检查失败

**症状**: Health check 一直返回 unhealthy

**解决方案**:
1. 检查应用是否完全启动（查看日志）
2. 验证 `SERVER_PORT` 环境变量是否正确
3. 确认 Spring Boot Actuator 端点已启用
4. 手动测试健康检查端点：
```bash
curl http://localhost:8080/actuator/health
```

### 🚀 性能优化建议

#### 1. JVM 调优

在 Dockerfile 中的 JVM 参数已经过优化，但您可以根据实际负载进行调整：

```dockerfile
# 增加堆内存（如果有更多 RAM）
-Xms1g -Xmx4g

# 优化 GC 性能
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-XX:ParallelGCThreads=4
-XX:ConcGCThreads=2
```

#### 2. 数据库连接池

优化 Spring Boot 的数据库连接池设置：

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
```

#### 3. Redis 配置

使用 Redis 连接池提高性能：

```yaml
spring:
  redis:
    lettuce:
      pool:
        max-active: 8
        max-idle: 8
        min-idle: 2
```

#### 4. 容器资源分配

根据实际负载选择合适的 GPU 和 CPU：
- 轻量级工作负载：RTX 4090 + 8 vCPU
- 中等工作负载：A100 + 16 vCPU
- 重度工作负载：多个 A100 + 32 vCPU

#### 5. 缓存策略

启用应用级缓存以减少数据库查询：

```yaml
spring:
  cache:
    type: redis
    redis:
      time-to-live: 3600000
```

### 📊 监控和日志

#### 1. 查看应用日志

在 RunPod 控制台中：
- 导航到您的 Endpoint
- 点击 "Logs" 标签
- 查看实时日志输出

#### 2. 监控指标

使用 Spring Boot Actuator 提供的监控端点：

```bash
# 健康状态
curl http://your-endpoint/actuator/health

# 应用信息
curl http://your-endpoint/actuator/info

# 指标数据
curl http://your-endpoint/actuator/metrics
```

#### 3. 性能监控

建议集成以下监控工具：
- Prometheus + Grafana（指标监控）
- ELK Stack（日志聚合）
- Sentry（错误追踪）

### 🔒 安全最佳实践

1. **环境变量管理**
   - 使用 RunPod 的环境变量功能存储敏感信息
   - 不要在代码或配置文件中硬编码密码

2. **网络安全**
   - 限制数据库和 Redis 的访问源 IP
   - 使用 SSL/TLS 加密数据传输
   - 配置防火墙规则

3. **API 安全**
   - 启用 API 认证和授权
   - 使用 API 密钥管理访问
   - 实施速率限制

4. **定期更新**
   - 定期更新依赖库
   - 关注安全漏洞公告
   - 及时打补丁

### 📚 相关资源

- [RuoYi AI 官方文档](https://doc.pandarobot.chat)
- [RunPod 官方文档](https://docs.runpod.io/)
- [Spring Boot 文档](https://spring.io/projects/spring-boot)
- [Docker 最佳实践](https://docs.docker.com/develop/dev-best-practices/)

### 💬 获取帮助

如果遇到问题，可以通过以下渠道获取帮助：

- GitHub Issues: https://github.com/hhongli1979-coder/ruoyi-ai/issues
- 项目文档: https://doc.pandarobot.chat
- RunPod 社区: https://discord.gg/runpod

---

## English Documentation

### 📖 Overview

This guide will help you deploy the RuoYi AI Enterprise AI Assistant Platform on RunPod Serverless. RuoYi AI integrates mainstream AI platforms such as FastGPT, Coze, and DIFY, providing powerful features like RAG (Retrieval-Augmented Generation), Knowledge Graphs, and Digital Humans.

### 🎯 RunPod Platform Introduction

RunPod is a GPU cloud platform specifically designed for AI/ML workloads. Its Serverless functionality allows you to:
- Use GPU resources on-demand without upfront costs
- Automatically scale to handle different workloads
- Pay only for the compute resources you actually use
- Quickly deploy containerized applications

### 🔧 Pre-Deployment Preparation

Before deploying RuoYi AI to RunPod, ensure you have the following resources ready:

#### 1. Database Service

**MySQL 8.0+**
- You can use cloud database services (e.g., AWS RDS, Alibaba Cloud RDS, Tencent Cloud CDB)
- Or set up your own MySQL server
- Create database: `ruoyi-ai`
- Import initialization SQL scripts (located in project `sql/` directory)

```sql
CREATE DATABASE `ruoyi-ai` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### 2. Redis Service

- Redis 5.0+ version
- You can use cloud Redis services (e.g., AWS ElastiCache, Alibaba Cloud Redis)
- Or set up your own Redis server
- Recommend enabling persistence to prevent data loss

#### 3. RunPod Account

- Register for a RunPod account: https://www.runpod.io/
- Add credits to your account (recommend at least $10 for testing)
- Obtain API key (optional, for API calls)

#### 4. External Service API Keys (Optional)

Depending on the features you need, prepare the corresponding API keys:
- OpenAI API Key (for GPT features)
- FastGPT API Key (if using FastGPT)
- Coze API Key (if using Coze platform)
- DIFY API Key (if using DIFY)

### 📝 Detailed Deployment Steps

#### Step 1: Build Docker Image

1. **Clone the project repository**
```bash
git clone https://github.com/hhongli1979-coder/ruoyi-ai.git
cd ruoyi-ai
```

2. **Build Docker image**
```bash
docker build -t your-dockerhub-username/ruoyi-ai:latest .
```

3. **Push image to Docker Hub**
```bash
docker login
docker push your-dockerhub-username/ruoyi-ai:latest
```

> **Note**: You can also use other container registries like GitHub Container Registry or private registries.

#### Step 2: Create Serverless Endpoint on RunPod

1. **Log in to RunPod Console**
   - Visit https://www.runpod.io/console/serverless

2. **Create a new Serverless Endpoint**
   - Click the "New Endpoint" button
   - Fill in Endpoint name: `ruoyi-ai`

3. **Configure Container Image**
   - Container Image: `your-dockerhub-username/ruoyi-ai:latest`
   - Container Disk: 30 GB (recommended)
   - GPU Type: Choose appropriate GPU (recommend RTX 4090 or A100)

4. **Configure Environment Variables**

Required environment variables:
```
MYSQL_HOST=your-mysql-host.com
MYSQL_PORT=3306
MYSQL_DATABASE=ruoyi-ai
MYSQL_USER=your-mysql-user
MYSQL_PASSWORD=your-mysql-password
REDIS_HOST=your-redis-host.com
REDIS_PORT=6379
```

Optional environment variables:
```
REDIS_PASSWORD=your-redis-password
OPENAI_API_KEY=sk-xxxxxxxxxxxx
SERVER_PORT=8080
SPRING_PROFILES_ACTIVE=prod
```

#### Step 3: Deploy and Test

1. **Deploy Endpoint**
   - After confirming all configurations are correct, click "Deploy" button
   - Wait for container to start (first start may take 2-5 minutes)

2. **Check Deployment Status**
   - View Endpoint status in RunPod console
   - Check log output to confirm application started successfully
   - Look for "RuoYiAI启动成功" message in logs

3. **Health Check Test**

Send test request using RunPod API or Web interface:

```json
{
  "input": {
    "action": "health_check"
  }
}
```

Expected response:
```json
{
  "status": "healthy",
  "application": "RuoYi AI",
  "details": {
    "status": "UP"
  }
}
```

### 🎮 API Usage Examples

#### 1. Health Check

**Request**:
```json
{
  "input": {
    "action": "health_check"
  }
}
```

**Response**:
```json
{
  "status": "healthy",
  "application": "RuoYi AI",
  "details": {...}
}
```

#### 2. Service Status Query

**Request**:
```json
{
  "input": {
    "action": "status"
  }
}
```

**Response**:
```json
{
  "status": "running",
  "health": {...},
  "server_url": "http://localhost:8080",
  "timestamp": 1642584000.0
}
```

#### 3. AI Chat Interface

**Request**:
```json
{
  "input": {
    "action": "chat",
    "message": "Hello, please introduce the RuoYi AI platform"
  }
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "message": "RuoYi AI is an...",
    "timestamp": "2024-01-20T10:30:00Z"
  }
}
```

### 🔍 Environment Variables Detailed Description

| Variable Name | Description | Default | Required |
|---------------|-------------|---------|----------|
| `MYSQL_HOST` | MySQL database host address | - | ✅ |
| `MYSQL_PORT` | MySQL database port | 3306 | ❌ |
| `MYSQL_DATABASE` | Database name | ruoyi-ai | ❌ |
| `MYSQL_USER` | Database username | - | ✅ |
| `MYSQL_PASSWORD` | Database password | - | ✅ |
| `REDIS_HOST` | Redis server address | - | ✅ |
| `REDIS_PORT` | Redis server port | 6379 | ❌ |
| `REDIS_PASSWORD` | Redis password | "" | ❌ |
| `OPENAI_API_KEY` | OpenAI API key | "" | ❌ |
| `SERVER_PORT` | Application server port | 8080 | ❌ |
| `SPRING_PROFILES_ACTIVE` | Spring Boot profile | prod | ❌ |

### ⚠️ Troubleshooting

#### Issue 1: Container Fails to Start

**Symptoms**: Container exits immediately after starting

**Possible Causes and Solutions**:
1. Check if environment variables are correctly configured
2. Verify database connection information
3. Check container logs for detailed error information
4. Ensure MySQL database is created and initialization scripts are imported

#### Issue 2: Database Connection Failure

**Symptoms**: Logs show "Unable to connect to database"

**Solutions**:
1. Confirm database host address is accessible from RunPod
2. Check if database username and password are correct
3. Verify database firewall rules allow connections from RunPod
4. Test database connection:
```bash
mysql -h MYSQL_HOST -u MYSQL_USER -p
```

#### Issue 3: Redis Connection Failure

**Symptoms**: Logs show Redis-related errors

**Solutions**:
1. Verify Redis server address and port
2. If Redis has password set, ensure `REDIS_PASSWORD` is correctly configured
3. Check Redis firewall rules
4. Test Redis connection:
```bash
redis-cli -h REDIS_HOST -p REDIS_PORT -a REDIS_PASSWORD
```

#### Issue 4: Slow Application Startup

**Symptoms**: Application takes a long time to be ready

**Solutions**:
1. This is normal; Java applications typically take 30-120 seconds to start
2. You can adjust JVM parameters in Dockerfile to optimize startup time
3. Use faster storage types (e.g., NVMe SSD)
4. Check database and Redis response speeds

#### Issue 5: Health Check Failure

**Symptoms**: Health check continuously returns unhealthy

**Solutions**:
1. Check if application has fully started (view logs)
2. Verify `SERVER_PORT` environment variable is correct
3. Confirm Spring Boot Actuator endpoints are enabled
4. Manually test health check endpoint:
```bash
curl http://localhost:8080/actuator/health
```

### 🚀 Performance Optimization Recommendations

#### 1. JVM Tuning

JVM parameters in Dockerfile are already optimized, but you can adjust based on actual load:

```dockerfile
# Increase heap memory (if more RAM available)
-Xms1g -Xmx4g

# Optimize GC performance
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-XX:ParallelGCThreads=4
-XX:ConcGCThreads=2
```

#### 2. Database Connection Pool

Optimize Spring Boot database connection pool settings:

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
```

#### 3. Redis Configuration

Use Redis connection pool to improve performance:

```yaml
spring:
  redis:
    lettuce:
      pool:
        max-active: 8
        max-idle: 8
        min-idle: 2
```

#### 4. Container Resource Allocation

Choose appropriate GPU and CPU based on actual load:
- Lightweight workloads: RTX 4090 + 8 vCPU
- Medium workloads: A100 + 16 vCPU
- Heavy workloads: Multiple A100 + 32 vCPU

#### 5. Caching Strategy

Enable application-level caching to reduce database queries:

```yaml
spring:
  cache:
    type: redis
    redis:
      time-to-live: 3600000
```

### 📊 Monitoring and Logging

#### 1. View Application Logs

In RunPod console:
- Navigate to your Endpoint
- Click "Logs" tab
- View real-time log output

#### 2. Monitoring Metrics

Use monitoring endpoints provided by Spring Boot Actuator:

```bash
# Health status
curl http://your-endpoint/actuator/health

# Application info
curl http://your-endpoint/actuator/info

# Metrics data
curl http://your-endpoint/actuator/metrics
```

#### 3. Performance Monitoring

Recommend integrating the following monitoring tools:
- Prometheus + Grafana (metrics monitoring)
- ELK Stack (log aggregation)
- Sentry (error tracking)

### 🔒 Security Best Practices

1. **Environment Variable Management**
   - Use RunPod's environment variable feature to store sensitive information
   - Don't hardcode passwords in code or configuration files

2. **Network Security**
   - Restrict database and Redis access source IPs
   - Use SSL/TLS to encrypt data transmission
   - Configure firewall rules

3. **API Security**
   - Enable API authentication and authorization
   - Use API keys to manage access
   - Implement rate limiting

4. **Regular Updates**
   - Regularly update dependency libraries
   - Follow security vulnerability announcements
   - Apply patches promptly

### 📚 Related Resources

- [RuoYi AI Official Documentation](https://doc.pandarobot.chat)
- [RunPod Official Documentation](https://docs.runpod.io/)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

### 💬 Get Help

If you encounter problems, you can get help through the following channels:

- GitHub Issues: https://github.com/hhongli1979-coder/ruoyi-ai/issues
- Project Documentation: https://doc.pandarobot.chat
- RunPod Community: https://discord.gg/runpod

---

**Version**: 1.0.0  
**Last Updated**: January 2024  
**Maintainer**: RuoYi AI Team
