# RuoYi AI Copilot - AI编码助手

[English](README_EN.md) | 中文

基于 Spring AI 框架构建的智能编码助手，集成 MCP 工具协议，支持项目分析、代码生成、智能编辑和项目脚手架等功能。通过自然语言交互，帮助开发者快速完成各种编程任务。

> **注**: 本模块基于 [Spring AI Alibaba Copilot](https://github.com/spring-ai-alibaba/copilot) 项目构建

## ✨ 核心特性

### 🛠️ 智能文件操作
- **文件读取**: 支持分页读取大文件，自动处理编码
- **文件写入**: 创建/覆盖文件，支持差异化展示
- **智能编辑**: 基于查找替换的智能编辑，自动生成 diff
- **目录浏览**: 递归/非递归目录遍历

### 🤖 AI 驱动工具
- **项目分析**: 自动分析项目结构、依赖、配置文件
- **代码生成**: 基于模板的项目脚手架生成
- **智能重构**: 多文件智能编辑，理解项目上下文
- **持续对话**: 支持最多 20 轮工具调用链，自动完成复杂任务

### 📊 实时监控
- **SSE 流式日志**: 实时展示工具执行进度
- **任务状态跟踪**: 监控任务执行状态和结果
- **详细执行日志**: 记录每次工具调用的详细信息

## 🚀 快速开始

### 系统要求

- Java 17+
- Maven 3.6+
- 阿里云通义千问 API Key（或 OpenAI API Key）

### 1. 配置 API Key

编辑 `src/main/resources/application.yml`:

```yaml
spring:
  ai:
    openai:
      base-url: https://dashscope.aliyuncs.com/compatible-mode
      api-key: sk-your-api-key  # 替换为你的 API Key
      chat:
        options:
          model: qwen-plus
```

### 2. 配置工作目录

```yaml
app:
  workspace:
    root-directory: ${user.dir}/workspace  # 工作目录路径
    max-file-size: 10485760  # 10MB
    allowed-extensions:
      - .txt
      - .md
      - .java
      - .js
      - .ts
      - .json
      - .xml
      - .yml
      - .yaml
```

### 3. 启动应用

```bash
cd ruoyi-extend/ruoyi-ai-copilot
mvn spring-boot:run
```

应用将在 `http://localhost:8080` 启动，浏览器会自动打开。

## 📚 使用指南

### 基本对话

在聊天界面输入自然语言指令，AI 助手会自动选择合适的工具完成任务：

```
示例1: "帮我在 workspace 目录下创建一个 Spring Boot 项目"
示例2: "读取 pom.xml 文件的内容"
示例3: "将所有 Java 文件中的 oldName 替换为 newName"
示例4: "分析当前项目的结构和依赖"
```

### 支持的项目类型

AI Copilot 能够识别并生成以下类型的项目：

- **Java**: Maven, Gradle, Spring Boot
- **前端**: Node.js, React, Vue, Angular
- **Python**: Standard Python, Django, Flask
- **其他**: 通用项目

### 工具执行流程

```
用户输入 → ChatController 接收
    ↓
判断是否需要工具执行
    ↓
启动异步对话任务（返回 taskId）
    ↓
AI 模型决策 → 调用工具
    ↓
工具执行 → AOP 拦截记录
    ↓
SSE 流式推送日志 → 前端实时展示
    ↓
持续对话（最多 20 轮）
    ↓
任务完成 → 返回最终结果
```

## 🔧 配置说明

### 安全配置

```yaml
app:
  security:
    approval-mode: DEFAULT  # DEFAULT(需要确认), AUTO_EDIT(自动编辑), YOLO(全自动)
    dangerous-commands:  # 禁止执行的危险命令
      - rm
      - del
      - format
```

### 工具配置

```yaml
app:
  tools:
    read-file:
      enabled: true
      max-lines-per-read: 1000
    write-file:
      enabled: true
      backup-enabled: true
    edit-file:
      enabled: true
      diff-context-lines: 3
    list-directory:
      enabled: true
      max-depth: 5
```

### 浏览器自动打开

```yaml
app:
  browser:
    auto-open: true  # 是否自动打开浏览器
    url: http://localhost:${server.port:8080}
    delay-seconds: 2  # 启动后延迟打开时间
```

## 🏗️ 技术架构

### 核心技术栈

- **Spring Boot 3.4.5**: 应用框架
- **Spring AI 1.0.0**: AI 集成框架
- **MCP Client**: 模型上下文协议客户端
- **AspectJ**: AOP 切面编程
- **Jackson**: JSON 处理
- **Java Diff Utils**: 文件差异比较

### 主要模块

```
ruoyi-ai-copilot/
├── config/                 # 配置类
│   ├── SpringAIConfiguration.java    # AI 客户端配置
│   ├── AppProperties.java            # 应用属性
│   └── ToolCallLoggingAspect.java    # 工具调用切面
├── controller/             # 控制器
│   ├── ChatController.java           # 聊天接口
│   ├── LogStreamController.java      # 日志流接口
│   └── TaskStatusController.java     # 任务状态接口
├── service/                # 服务层
│   ├── ContinuousConversationService.java  # 持续对话
│   ├── ProjectContextAnalyzer.java         # 项目分析
│   ├── ProjectTypeDetector.java            # 项目类型检测
│   └── ProjectTemplateService.java         # 项目模板
├── tools/                  # AI 工具
│   ├── FileOperationTools.java       # 文件操作工具
│   ├── SmartEditTool.java            # 智能编辑
│   ├── AnalyzeProjectTool.java       # 项目分析
│   └── ProjectScaffoldTool.java      # 项目脚手架
└── model/                  # 数据模型
    ├── ProjectContext.java           # 项目上下文
    └── TaskStatus.java               # 任务状态
```

## 📖 API 接口

### 1. 发送聊天消息

**POST** `/api/chat/message`

```json
{
  "message": "帮我创建一个 Spring Boot 项目",
  "conversationId": "optional-conversation-id"
}
```

**响应**:
```json
{
  "response": "AI 回复内容",
  "taskId": "任务ID（如果启动了异步任务）"
}
```

### 2. 实时日志流

**GET** `/api/logs/stream/{taskId}`

通过 SSE 接收实时日志：

```javascript
const eventSource = new EventSource(`/api/logs/stream/${taskId}`);
eventSource.onmessage = (event) => {
  const log = JSON.parse(event.data);
  console.log(log);
};
```

### 3. 查询任务状态

**GET** `/api/task/status/{taskId}`

```json
{
  "taskId": "task-123",
  "status": "RUNNING",
  "result": "执行结果"
}
```

## 🔒 安全特性

- **工作空间隔离**: 所有操作限制在配置的工作目录内
- **文件类型白名单**: 只允许操作配置的文件扩展名
- **文件大小限制**: 默认最大 10MB
- **路径验证**: 防止目录遍历攻击
- **危险命令拦截**: 可配置的危险命令黑名单

## 🐛 常见问题

### Q1: API Key 无效

**A**: 检查 `application.yml` 中的 API Key 是否正确配置，确保有足够的额度。

### Q2: 工具执行失败

**A**: 检查以下几点：
1. 工作目录是否存在且有读写权限
2. 文件扩展名是否在白名单中
3. 文件大小是否超过限制
4. 查看控制台日志获取详细错误信息

### Q3: 浏览器未自动打开

**A**: 检查 `app.browser.auto-open` 配置，或手动访问 `http://localhost:8080`

## 🤝 参与贡献

欢迎提交 Issue 和 Pull Request！

## 📄 开源协议

本项目采用 Apache License 2.0 许可证。

## 🙏 致谢

- [Spring AI](https://spring.io/projects/spring-ai) - AI 集成框架
- [Spring AI Alibaba Copilot](https://github.com/spring-ai-alibaba/copilot) - 原始项目
- [Model Context Protocol](https://modelcontextprotocol.io/) - 工具协议标准
