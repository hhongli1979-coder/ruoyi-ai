# RuoYi AI - RunPod 快速部署指南

[![RunPod](https://api.runpod.io/badge/hhongli1979-coder/ruoyi-ai)](https://console.runpod.io/hub/hhongli1979-coder/ruoyi-ai)

## 📖 简介

本指南提供 RuoYi AI 在 RunPod Serverless 平台上的快速部署方法。使用本指南，您可以在几分钟内将 RuoYi AI 部署到 RunPod 云端。

## ⚡ 快速开始

### 前提条件

在开始部署之前，请确保您已准备好：

1. **RunPod 账号**
   - 注册地址：https://www.runpod.io/
   - 建议充值 $10 用于测试

2. **MySQL 数据库** (8.0+)
   - 可使用云数据库服务（如阿里云RDS、腾讯云CDB等）
   - 需创建数据库：`ruoyi-ai`
   - 导入初始化 SQL 脚本（位于项目 `sql/` 目录）

3. **Redis 服务** (5.0+)
   - 可使用云 Redis 服务（如阿里云Redis、腾讯云Redis等）
   - 建议启用持久化

4. **Docker Hub 账号**
   - 注册地址：https://hub.docker.com/
   - 用于存储和分发您的容器镜像

### 方式一：使用自动化脚本（推荐）

我们提供了一键部署脚本，让您轻松完成镜像构建和推送：

#### 步骤 1：运行部署脚本

```bash
cd /path/to/ruoyi-ai
./script/deploy/runpod-deploy.sh
```

#### 步骤 2：按照提示操作

脚本会引导您完成以下操作：
1. 输入您的 Docker Hub 用户名
2. 选择镜像标签（默认：latest）
3. 登录 Docker Hub（如果需要）
4. 自动构建 Docker 镜像
5. 推送镜像到 Docker Hub

#### 步骤 3：在 RunPod 创建 Endpoint

1. 访问 [RunPod Serverless 控制台](https://www.runpod.io/console/serverless)

2. 点击 **"New Endpoint"** 创建新的端点

3. 填写基本信息：
   - **Endpoint Name**: `ruoyi-ai`
   - **Container Image**: `your-dockerhub-username/ruoyi-ai:latest`
   - **Container Disk**: `30 GB`

4. 选择 GPU 类型：
   - 推荐：RTX 4090 或 A100
   - 根据预算和性能需求选择

5. 配置环境变量：

**必需的环境变量：**
```bash
MYSQL_HOST=your-mysql-host.com
MYSQL_USER=your-mysql-user
MYSQL_PASSWORD=your-mysql-password
MYSQL_DATABASE=ruoyi-ai
REDIS_HOST=your-redis-host.com
```

**可选的环境变量：**
```bash
MYSQL_PORT=3306
REDIS_PORT=6379
REDIS_PASSWORD=your-redis-password
OPENAI_API_KEY=sk-xxxxxxxxxxxx
SERVER_PORT=8080
SPRING_PROFILES_ACTIVE=prod
```

6. 点击 **"Deploy"** 开始部署

#### 步骤 4：测试部署

等待 2-5 分钟后，在 RunPod 控制台发送测试请求：

```json
{
  "input": {
    "action": "health_check"
  }
}
```

如果返回以下响应，说明部署成功：

```json
{
  "status": "healthy",
  "application": "RuoYi AI",
  "details": {
    "status": "UP"
  }
}
```

### 方式二：手动部署

如果您更喜欢手动控制每一步，可以按照以下步骤操作：

#### 1. 构建 Docker 镜像

```bash
cd /path/to/ruoyi-ai
docker build -t your-dockerhub-username/ruoyi-ai:latest .
```

#### 2. 登录 Docker Hub

```bash
docker login
```

输入您的 Docker Hub 用户名和密码。

#### 3. 推送镜像

```bash
docker push your-dockerhub-username/ruoyi-ai:latest
```

#### 4. 在 RunPod 配置

按照"方式一"中的步骤 3-4 完成配置和测试。

## 🔍 环境变量说明

| 变量名 | 说明 | 默认值 | 是否必需 |
|--------|------|--------|---------|
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

## 🎮 API 使用示例

### 健康检查

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
  "details": {
    "status": "UP"
  }
}
```

### 服务状态查询

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

### AI 对话接口

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
    "message": "RuoYi AI 是一个企业级AI助手平台...",
    "timestamp": "2024-01-20T10:30:00Z"
  }
}
```

## ⚠️ 常见问题

### 问题 1: 容器启动失败

**症状**: 容器启动后立即退出

**解决方案**:
1. 检查所有必需的环境变量是否正确配置
2. 验证数据库和 Redis 连接信息
3. 查看 RunPod 控制台的日志获取详细错误信息
4. 确保 MySQL 数据库已创建并导入初始化脚本

### 问题 2: 数据库连接失败

**症状**: 日志显示 "Unable to connect to database"

**解决方案**:
1. 确认数据库主机地址可从 RunPod 访问
2. 检查数据库用户名和密码
3. 验证数据库防火墙规则，允许来自 RunPod 的连接
4. 确保数据库已创建且初始化脚本已导入

### 问题 3: Redis 连接失败

**症状**: 日志显示 Redis 相关错误

**解决方案**:
1. 验证 Redis 服务器地址和端口
2. 如果 Redis 设置了密码，确保 `REDIS_PASSWORD` 正确配置
3. 检查 Redis 防火墙规则

### 问题 4: 应用启动慢

**症状**: 应用需要很长时间才能准备就绪

**解决方案**:
1. 这是正常现象，Java 应用通常需要 30-120 秒启动
2. 可以在日志中查看启动进度
3. 确认数据库和 Redis 的响应速度正常

### 问题 5: 健康检查失败

**症状**: Health check 一直返回 unhealthy

**解决方案**:
1. 检查应用是否完全启动（查看日志中的启动成功消息）
2. 验证 `SERVER_PORT` 环境变量是否正确
3. 等待足够的时间（首次启动可能需要 2-5 分钟）

## 💡 最佳实践

1. **安全性**
   - 使用强密码保护数据库和 Redis
   - 定期更新依赖库和镜像
   - 不要在公开仓库中暴露敏感信息

2. **性能优化**
   - 根据实际负载选择合适的 GPU 类型
   - 配置合理的数据库连接池
   - 启用 Redis 缓存以提高性能

3. **监控和维护**
   - 定期查看 RunPod 日志
   - 监控应用性能指标
   - 及时更新到最新版本

## 📚 相关资源

- [完整部署指南（英文版）](.runpod/README.md)
- [RuoYi AI 官方文档](https://doc.pandarobot.chat)
- [RunPod 官方文档](https://docs.runpod.io/)
- [项目 GitHub 仓库](https://github.com/ageerle/ruoyi-ai)

## 💬 获取帮助

如果您在部署过程中遇到问题，可以：

1. 查看 [完整部署指南](.runpod/README.md) 获取详细信息
2. 在 [GitHub Issues](https://github.com/ageerle/ruoyi-ai/issues) 提交问题
3. 访问 [项目文档](https://doc.pandarobot.chat) 获取更多帮助
4. 加入社区群组交流（见主 README）

---

**祝您部署顺利！🎉**

如果本指南对您有帮助，请给项目点个 Star ⭐
