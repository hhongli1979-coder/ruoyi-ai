# RuoYi AI Copilot - AI Coding Assistant

English | [中文](README.md)

An intelligent coding assistant built on the Spring AI framework, integrating MCP tool protocol, supporting project analysis, code generation, intelligent editing, and project scaffolding. Help developers quickly complete various programming tasks through natural language interaction.

> **Note**: This module is based on the [Spring AI Alibaba Copilot](https://github.com/spring-ai-alibaba/copilot) project

## ✨ Core Features

### 🛠️ Intelligent File Operations
- **File Reading**: Supports paginated reading of large files with automatic encoding handling
- **File Writing**: Create/overwrite files with diff visualization
- **Smart Editing**: Intelligent editing based on find-and-replace with automatic diff generation
- **Directory Browsing**: Recursive/non-recursive directory traversal

### 🤖 AI-Driven Tools
- **Project Analysis**: Automatically analyze project structure, dependencies, and configuration files
- **Code Generation**: Template-based project scaffolding generation
- **Intelligent Refactoring**: Multi-file intelligent editing with project context understanding
- **Continuous Conversation**: Supports up to 20 rounds of tool call chains to automatically complete complex tasks

### 📊 Real-time Monitoring
- **SSE Streaming Logs**: Real-time display of tool execution progress
- **Task Status Tracking**: Monitor task execution status and results
- **Detailed Execution Logs**: Record detailed information of each tool call

## 🚀 Quick Start

### System Requirements

- Java 17+
- Maven 3.6+
- Alibaba Tongyi Qianwen API Key (or OpenAI API Key)

### 1. Configure API Key

Edit `src/main/resources/application.yml`:

```yaml
spring:
  ai:
    openai:
      base-url: https://dashscope.aliyuncs.com/compatible-mode
      api-key: sk-your-api-key  # Replace with your API Key
      chat:
        options:
          model: qwen-plus
```

### 2. Configure Workspace

```yaml
app:
  workspace:
    root-directory: ${user.dir}/workspace  # Workspace directory path
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

### 3. Start the Application

```bash
cd ruoyi-extend/ruoyi-ai-copilot
mvn spring-boot:run
```

The application will start at `http://localhost:8080`, and the browser will open automatically.

## 📚 Usage Guide

### Basic Conversation

Enter natural language commands in the chat interface, and the AI assistant will automatically select the appropriate tool to complete the task:

```
Example 1: "Help me create a Spring Boot project in the workspace directory"
Example 2: "Read the contents of the pom.xml file"
Example 3: "Replace oldName with newName in all Java files"
Example 4: "Analyze the structure and dependencies of the current project"
```

### Supported Project Types

AI Copilot can recognize and generate the following types of projects:

- **Java**: Maven, Gradle, Spring Boot
- **Frontend**: Node.js, React, Vue, Angular
- **Python**: Standard Python, Django, Flask
- **Others**: Generic projects

### Tool Execution Flow

```
User Input → ChatController receives
    ↓
Determine if tool execution is needed
    ↓
Start async conversation task (return taskId)
    ↓
AI model decides → Call tool
    ↓
Tool execution → AOP intercepts and records
    ↓
SSE streaming logs → Frontend real-time display
    ↓
Continuous conversation (up to 20 rounds)
    ↓
Task completed → Return final result
```

## 🔧 Configuration

### Security Configuration

```yaml
app:
  security:
    approval-mode: DEFAULT  # DEFAULT(requires confirmation), AUTO_EDIT(auto edit), YOLO(fully automatic)
    dangerous-commands:  # Blocked dangerous commands
      - rm
      - del
      - format
```

### Tool Configuration

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

### Browser Auto-open

```yaml
app:
  browser:
    auto-open: true  # Whether to automatically open the browser
    url: http://localhost:${server.port:8080}
    delay-seconds: 2  # Delay time after startup
```

## 🏗️ Technical Architecture

### Core Technology Stack

- **Spring Boot 3.4.5**: Application framework
- **Spring AI 1.0.0**: AI integration framework
- **MCP Client**: Model Context Protocol client
- **AspectJ**: AOP aspect-oriented programming
- **Jackson**: JSON processing
- **Java Diff Utils**: File diff comparison

### Main Modules

```
ruoyi-ai-copilot/
├── config/                 # Configuration classes
│   ├── SpringAIConfiguration.java    # AI client configuration
│   ├── AppProperties.java            # Application properties
│   └── ToolCallLoggingAspect.java    # Tool call aspect
├── controller/             # Controllers
│   ├── ChatController.java           # Chat interface
│   ├── LogStreamController.java      # Log stream interface
│   └── TaskStatusController.java     # Task status interface
├── service/                # Service layer
│   ├── ContinuousConversationService.java  # Continuous conversation
│   ├── ProjectContextAnalyzer.java         # Project analysis
│   ├── ProjectTypeDetector.java            # Project type detection
│   └── ProjectTemplateService.java         # Project templates
├── tools/                  # AI tools
│   ├── FileOperationTools.java       # File operation tools
│   ├── SmartEditTool.java            # Smart editing
│   ├── AnalyzeProjectTool.java       # Project analysis
│   └── ProjectScaffoldTool.java      # Project scaffolding
└── model/                  # Data models
    ├── ProjectContext.java           # Project context
    └── TaskStatus.java               # Task status
```

## 📖 API Reference

### 1. Send Chat Message

**POST** `/api/chat/message`

```json
{
  "message": "Help me create a Spring Boot project",
  "conversationId": "optional-conversation-id"
}
```

**Response**:
```json
{
  "response": "AI response content",
  "taskId": "Task ID (if async task started)"
}
```

### 2. Real-time Log Stream

**GET** `/api/logs/stream/{taskId}`

Receive real-time logs via SSE:

```javascript
const eventSource = new EventSource(`/api/logs/stream/${taskId}`);
eventSource.onmessage = (event) => {
  const log = JSON.parse(event.data);
  console.log(log);
};
```

### 3. Query Task Status

**GET** `/api/task/status/{taskId}`

```json
{
  "taskId": "task-123",
  "status": "RUNNING",
  "result": "Execution result"
}
```

## 🔒 Security Features

- **Workspace Isolation**: All operations are restricted to the configured workspace directory
- **File Type Whitelist**: Only configured file extensions are allowed
- **File Size Limit**: Default maximum 10MB
- **Path Validation**: Prevent directory traversal attacks
- **Dangerous Command Blocking**: Configurable blacklist of dangerous commands

## 🐛 Common Issues

### Q1: Invalid API Key

**A**: Check if the API Key in `application.yml` is correctly configured and has sufficient quota.

### Q2: Tool Execution Failed

**A**: Check the following:
1. Does the workspace directory exist and have read/write permissions?
2. Is the file extension in the whitelist?
3. Does the file size exceed the limit?
4. Check console logs for detailed error information

### Q3: Browser Did Not Open Automatically

**A**: Check the `app.browser.auto-open` configuration, or manually visit `http://localhost:8080`

## 🤝 Contributing

Issues and Pull Requests are welcome!

## 📄 License

This project is licensed under the Apache License 2.0.

## 🙏 Acknowledgments

- [Spring AI](https://spring.io/projects/spring-ai) - AI integration framework
- [Spring AI Alibaba Copilot](https://github.com/spring-ai-alibaba/copilot) - Original project
- [Model Context Protocol](https://modelcontextprotocol.io/) - Tool protocol standard
