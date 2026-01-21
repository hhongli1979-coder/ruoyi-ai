#!/bin/bash
##############################################
# RuoYi AI Copilot 快速启动脚本
# 功能：快速启动和管理 Docker 容器
##############################################

set -euo pipefail

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印信息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# 检查 .env 文件
check_env_file() {
    if [ ! -f .env ]; then
        print_warn ".env 文件不存在"
        print_info "正在从 .env.example 创建 .env 文件..."
        cp .env.example .env
        print_warn "请编辑 .env 文件，填入您的 API Key"
        print_info "nano .env  或  vim .env"
        exit 1
    fi
    
    # 检查 API Key 是否配置
    if grep -q "sk-your-api-key-here" .env; then
        print_error "请先在 .env 文件中配置您的 API Key"
        print_info "编辑文件: nano .env"
        exit 1
    fi
}

# 显示帮助
show_help() {
    cat << EOF
RuoYi AI Copilot 快速启动脚本

使用方法:
    ./docker-start.sh [命令]

命令:
    start       启动服务（默认）
    stop        停止服务
    restart     重启服务
    logs        查看日志
    status      查看状态
    build       重新构建镜像
    clean       清理容器和镜像
    help        显示帮助信息

示例:
    ./docker-start.sh start     # 启动服务
    ./docker-start.sh logs      # 查看日志
    ./docker-start.sh restart   # 重启服务

EOF
}

# 启动服务
start_service() {
    print_header "启动 RuoYi AI Copilot"
    check_env_file
    
    print_info "正在启动服务..."
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        print_info "✅ 服务启动成功！"
        echo ""
        print_info "服务地址: http://localhost:8080"
        print_info "查看日志: docker-compose logs -f"
        print_info "停止服务: docker-compose down"
        echo ""
        print_info "等待服务就绪..."
        sleep 5
        docker-compose ps
    else
        print_error "❌ 服务启动失败"
        exit 1
    fi
}

# 停止服务
stop_service() {
    print_header "停止 RuoYi AI Copilot"
    print_info "正在停止服务..."
    docker-compose down
    
    if [ $? -eq 0 ]; then
        print_info "✅ 服务已停止"
    else
        print_error "❌ 服务停止失败"
        exit 1
    fi
}

# 重启服务
restart_service() {
    print_header "重启 RuoYi AI Copilot"
    stop_service
    sleep 2
    start_service
}

# 查看日志
view_logs() {
    print_header "查看日志"
    print_info "按 Ctrl+C 退出日志查看"
    sleep 1
    docker-compose logs -f
}

# 查看状态
view_status() {
    print_header "服务状态"
    docker-compose ps
    echo ""
    print_info "容器详细信息:"
    docker ps --filter "name=ruoyi-ai-copilot" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

# 重新构建
rebuild_service() {
    print_header "重新构建镜像"
    print_info "正在重新构建..."
    docker-compose build --no-cache
    
    if [ $? -eq 0 ]; then
        print_info "✅ 镜像构建成功"
        print_info "使用 './docker-start.sh restart' 重启服务"
    else
        print_error "❌ 镜像构建失败"
        exit 1
    fi
}

# 清理
clean_service() {
    print_header "清理容器和镜像"
    print_warn "此操作将删除容器和镜像"
    
    # 检查是否为交互式终端
    if [ -t 0 ]; then
        read -p "确认继续? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "正在清理..."
            docker-compose down -v
            docker rmi ruoyi-ai-copilot:latest 2>/dev/null || true
            print_info "✅ 清理完成"
        else
            print_info "已取消"
        fi
    else
        print_warn "非交互式模式，跳过清理操作"
        print_info "使用 'docker-compose down -v' 手动清理"
    fi
}

# 主程序
main() {
    # 检查 Docker 和 docker-compose
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "docker-compose 未安装"
        exit 1
    fi
    
    # 解析命令
    case "${1:-start}" in
        start)
            start_service
            ;;
        stop)
            stop_service
            ;;
        restart)
            restart_service
            ;;
        logs)
            view_logs
            ;;
        status)
            view_status
            ;;
        build)
            rebuild_service
            ;;
        clean)
            clean_service
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

# 执行主程序
main "$@"
