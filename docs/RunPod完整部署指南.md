# RuoYi AI - RunPod 完整项目部署指南

[![RunPod](https://api.runpod.io/badge/hhongli1979-coder/ruoyi-ai)](https://console.runpod.io/hub/hhongli1979-coder/ruoyi-ai)

## 📖 项目架构

RuoYi AI 是一个完整的企业级 AI 助手平台，包含以下三个主要组件：

```
┌─────────────────────────────────────────────────────────────┐
│                     RuoYi AI 完整架构                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │              │    │              │    │              │  │
│  │  用户前端     │    │  管理后台     │    │   后端 API   │  │
│  │  ruoyi-web   │◄───┤ ruoyi-admin  │◄───┤  ruoyi-ai    │  │
│  │  (Vue 3)     │    │  (Vue 3)     │    │ (Spring Boot)│  │
│  │              │    │              │    │              │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│                                                │            │
│                                                │            │
│                                    ┌───────────▼─────────┐  │
│                                    │                     │  │
│                                    │  MySQL + Redis      │  │
│                                    │  (数据存储)          │  │
│                                    │                     │  │
│                                    └─────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 组件说明

| 组件 | 仓库 | 技术栈 | 用途 |
|------|------|--------|------|
| **后端 API** | [ruoyi-ai](https://github.com/hhongli1979-coder/ruoyi-ai) | Spring Boot 3.4 + Java 17 | AI 服务、数据处理、API 接口 |
| **管理后台** | [ruoyi-admin](https://github.com/hhongli1979-coder/ruoyi-admin) | Vue 3 + Vben Admin | 系统管理、配置、监控 |
| **用户前端** | [ruoyi-web](https://github.com/hhongli1979-coder/ruoyi-web) | Vue 3 | 用户交互、AI 对话界面 |

## 🚀 快速部署

### 前提条件

在开始部署之前，请确保已准备：

- [x] **RunPod 账号** - [注册地址](https://www.runpod.io/)
- [x] **Docker Hub 账号** - [注册地址](https://hub.docker.com/)
- [x] **MySQL 8.0+** - 云数据库或自建服务器
- [x] **Redis 5.0+** - 云 Redis 或自建服务器
- [x] **本地环境** - Docker 和 Git 已安装

### 方式一：使用自动化脚本（推荐）

#### 1. 运行完整部署脚本

```bash
cd /path/to/ruoyi-ai
./script/deploy/runpod-deploy-full.sh
```

#### 2. 选择部署组件

脚本会提示您选择要部署的组件：

```
1) 仅后端 API / Backend API only
2) 后端 + 管理后台 / Backend + Admin Frontend  
3) 完整项目 (后端 + 管理后台 + 用户前端) / Full Stack
```

推荐选择：
- **开发/测试环境**：选项 2（后端 + 管理后台）
- **生产环境**：选项 3（完整项目）

#### 3. 按提示完成构建

脚本会自动：
- ✅ 克隆所需的前端仓库
- ✅ 构建所有组件的 Docker 镜像
- ✅ 推送镜像到 Docker Hub
- ✅ 显示 RunPod 配置说明

### 方式二：手动分步部署

#### 步骤 1：构建后端镜像

```bash
# 克隆后端仓库
git clone https://github.com/hhongli1979-coder/ruoyi-ai.git
cd ruoyi-ai

# 构建后端镜像
docker build -t your-username/ruoyi-ai-backend:latest .

# 推送镜像
docker push your-username/ruoyi-ai-backend:latest
```

#### 步骤 2：构建管理后台镜像

```bash
# 克隆管理后台仓库
git clone https://github.com/hhongli1979-coder/ruoyi-admin.git
cd ruoyi-admin

# 构建管理后台镜像
docker build -f scripts/deploy/Dockerfile -t your-username/ruoyi-ai-admin:latest .

# 推送镜像
docker push your-username/ruoyi-ai-admin:latest
```

#### 步骤 3：构建用户前端镜像（可选）

```bash
# 克隆用户前端仓库
git clone https://github.com/hhongli1979-coder/ruoyi-web.git
cd ruoyi-web

# 构建用户前端镜像（如果有 Dockerfile）
docker build -t your-username/ruoyi-ai-web:latest .

# 推送镜像
docker push your-username/ruoyi-ai-web:latest
```

## ☁️ RunPod 部署配置

### 部署架构选择

#### 架构 A：微服务架构（推荐生产环境）

为每个组件创建独立的 Serverless Endpoint，实现独立扩展和管理。

**优势**：
- ✅ 独立扩展：每个组件可以根据负载独立调整
- ✅ 故障隔离：单个组件故障不影响其他组件
- ✅ 灵活更新：可以独立更新某个组件
- ✅ 资源优化：按需分配 GPU 资源

**步骤**：

##### 1. 创建后端 API Endpoint

访问：https://www.runpod.io/console/serverless

**配置**：
- **Endpoint Name**: `ruoyi-ai-backend`
- **Container Image**: `your-username/ruoyi-ai-backend:latest`
- **Container Disk**: 30 GB
- **GPU Type**: RTX 4090 或 A100

**环境变量**：
```bash
# 必需
MYSQL_HOST=your-mysql-host.com
MYSQL_PORT=3306
MYSQL_DATABASE=ruoyi-ai
MYSQL_USER=your-mysql-user
MYSQL_PASSWORD=your-mysql-password
REDIS_HOST=your-redis-host.com
REDIS_PORT=6379

# 可选
REDIS_PASSWORD=your-redis-password
OPENAI_API_KEY=sk-xxxxxxxxxxxx
SERVER_PORT=8080
SPRING_PROFILES_ACTIVE=prod
```

##### 2. 创建管理后台 Endpoint

**配置**：
- **Endpoint Name**: `ruoyi-ai-admin`
- **Container Image**: `your-username/ruoyi-ai-admin:latest`
- **Container Disk**: 10 GB
- **GPU Type**: CPU only（前端不需要 GPU）

**环境变量**：
```bash
VITE_API_URL=https://your-backend-endpoint-url
```

##### 3. 创建用户前端 Endpoint

**配置**：
- **Endpoint Name**: `ruoyi-ai-web`
- **Container Image**: `your-username/ruoyi-ai-web:latest`
- **Container Disk**: 10 GB
- **GPU Type**: CPU only

**环境变量**：
```bash
VITE_API_URL=https://your-backend-endpoint-url
```

#### 架构 B：单体架构（适合开发/测试）

将所有组件部署在一个容器中，简化部署和管理。

**优势**：
- ✅ 简单部署：只需要管理一个容器
- ✅ 成本较低：共享资源，减少费用
- ✅ 快速启动：适合开发和测试环境

**限制**：
- ❌ 无法独立扩展
- ❌ 更新需要重启所有服务

（此架构需要自定义 Dockerfile 集成所有组件）

## 🔍 环境变量详细说明

### 后端 API 环境变量

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

### 前端环境变量

| 变量名 | 说明 | 示例 | 必需 |
|--------|------|------|------|
| `VITE_API_URL` | 后端 API 地址 | https://api.example.com | ✅ |
| `VITE_APP_TITLE` | 应用标题 | RuoYi AI | ❌ |

## 🎮 API 测试

部署完成后，可以使用以下请求测试后端 API：

### 健康检查

```json
{
  "input": {
    "action": "health_check"
  }
}
```

**预期响应**：
```json
{
  "status": "healthy",
  "application": "RuoYi AI",
  "details": {
    "status": "UP"
  }
}
```

### 服务状态

```json
{
  "input": {
    "action": "status"
  }
}
```

### AI 对话测试

```json
{
  "input": {
    "action": "chat",
    "message": "你好，请介绍一下 RuoYi AI 平台"
  }
}
```

## ⚠️ 常见问题

### 问题 1：前后端连接失败

**症状**：管理后台或用户前端无法访问后端 API

**解决方案**：
1. 检查前端的 `VITE_API_URL` 环境变量是否正确设置
2. 确认后端 Endpoint 已启动并正常运行
3. 检查后端是否启用了 CORS
4. 测试后端 API 健康检查端点

### 问题 2：镜像构建失败

**症状**：Docker 构建过程中出现错误

**解决方案**：
1. 检查网络连接，确保可以访问 Docker Hub 和 npm/Maven 仓库
2. 如果是前端构建失败，检查 Node.js 版本（需要 >= 20.10.0）
3. 如果是后端构建失败，检查 Java 版本（需要 17）
4. 查看完整的构建日志定位具体错误

### 问题 3：容器启动后无法访问

**症状**：容器运行正常但无法访问服务

**解决方案**：
1. 检查容器的端口配置是否正确
2. 确认防火墙规则允许相应端口的访问
3. 查看容器日志检查是否有启动错误
4. 对于前端服务，确认 Nginx 配置正确

### 问题 4：数据库连接超时

**症状**：后端无法连接到 MySQL 或 Redis

**解决方案**：
1. 确认数据库主机地址从 RunPod 可以访问
2. 检查数据库防火墙规则，允许来自 RunPod 的连接
3. 验证数据库用户名、密码和端口是否正确
4. 测试数据库连接：
   ```bash
   mysql -h MYSQL_HOST -u MYSQL_USER -p
   redis-cli -h REDIS_HOST -p REDIS_PORT
   ```

## 🚀 性能优化建议

### 1. 资源分配

**后端 API**：
- GPU：RTX 4090 或 A100（用于 AI 推理）
- vCPU：8-16 核
- 内存：16-32 GB

**管理后台/用户前端**：
- GPU：不需要（纯静态服务）
- vCPU：2-4 核
- 内存：2-4 GB

### 2. 缓存策略

启用 Redis 缓存以提高性能：

```yaml
spring:
  cache:
    type: redis
    redis:
      time-to-live: 3600000  # 1 小时
```

### 3. 数据库优化

配置数据库连接池：

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
```

### 4. 前端优化

- 启用 Gzip 压缩
- 配置浏览器缓存
- 使用 CDN 加速静态资源

## 📊 监控和日志

### 后端监控

使用 Spring Boot Actuator 端点：

```bash
# 健康状态
curl https://your-backend-url/actuator/health

# 应用信息
curl https://your-backend-url/actuator/info

# 指标数据
curl https://your-backend-url/actuator/metrics
```

### 前端监控

在 Nginx 配置中启用访问日志：

```nginx
access_log /var/log/nginx/access.log;
error_log /var/log/nginx/error.log;
```

### 日志聚合

推荐集成：
- **ELK Stack** - 日志聚合和分析
- **Prometheus + Grafana** - 指标监控
- **Sentry** - 错误追踪

## 🔒 安全最佳实践

1. **环境变量管理**
   - 使用 RunPod 的环境变量功能存储敏感信息
   - 不要在代码中硬编码密码或密钥

2. **网络安全**
   - 限制数据库访问源 IP
   - 使用 SSL/TLS 加密数据传输
   - 配置防火墙规则

3. **API 安全**
   - 启用 API 认证和授权
   - 实施速率限制
   - 使用 HTTPS

4. **定期更新**
   - 定期更新依赖库
   - 关注安全漏洞公告
   - 及时应用安全补丁

## 📚 相关资源

- **项目文档**：https://doc.pandarobot.chat
- **RunPod 文档**：https://docs.runpod.io/
- **Spring Boot 文档**：https://spring.io/projects/spring-boot
- **Vue.js 文档**：https://vuejs.org/

## 💬 获取帮助

如果您在部署过程中遇到问题：

1. 查看 [完整部署指南](.runpod/README.md) 获取详细信息
2. 在 [GitHub Issues](https://github.com/hhongli1979-coder/ruoyi-ai/issues) 提交问题
3. 访问 [项目文档](https://doc.pandarobot.chat) 获取更多帮助
4. 加入社区群组交流（见主 README）

---

**部署成功！🎉**

如果本指南对您有帮助，请给项目点个 Star ⭐

**版本**：v2.0  
**更新日期**：2026年1月  
**维护者**：RuoYi AI Team
