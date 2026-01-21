# Multi-stage build for RuoYi AI - Optimized for RunPod Serverless
# Stage 1: Build stage
FROM maven:3.9-eclipse-temurin-17 AS builder

# Set working directory
WORKDIR /build

# Copy pom files and download dependencies (cache layer)
COPY pom.xml .
COPY ruoyi-admin/pom.xml ./ruoyi-admin/
COPY ruoyi-common/pom.xml ./ruoyi-common/
COPY ruoyi-extend/pom.xml ./ruoyi-extend/
COPY ruoyi-modules/pom.xml ./ruoyi-modules/
COPY ruoyi-modules-api/pom.xml ./ruoyi-modules-api/

# Download dependencies (this layer will be cached)
RUN mvn dependency:go-offline -B || true

# Copy source code
COPY . .

# Build the application
RUN mvn clean package -DskipTests -B

# Stage 2: Runtime stage
FROM eclipse-temurin:17-jre-alpine

# Install Python 3 and required packages for handler script
RUN apk add --no-cache python3 py3-pip curl bash git \
    && pip3 install --break-system-packages --no-cache-dir requests runpod

# Set working directory
WORKDIR /app

# Copy the built jar from builder stage
COPY --from=builder /build/ruoyi-admin/target/ruoyi-admin.jar /app/ruoyi-admin.jar

# Copy the handler script
COPY src/handler.py /app/handler.py

# Create a startup script
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'java -Xms512m -Xmx2g \' >> /app/start.sh && \
    echo '  -XX:+UseG1GC \' >> /app/start.sh && \
    echo '  -XX:MaxGCPauseMillis=200 \' >> /app/start.sh && \
    echo '  -XX:+UnlockExperimentalVMOptions \' >> /app/start.sh && \
    echo '  -XX:+UseContainerSupport \' >> /app/start.sh && \
    echo '  -Djava.security.egd=file:/dev/./urandom \' >> /app/start.sh && \
    echo '  -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE:-prod} \' >> /app/start.sh && \
    echo '  -Dserver.port=${SERVER_PORT:-8080} \' >> /app/start.sh && \
    echo '  -jar ruoyi-admin.jar &' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo '# Wait for application to start' >> /app/start.sh && \
    echo 'echo "Waiting for Spring Boot application to start..."' >> /app/start.sh && \
    echo 'for i in {1..60}; do' >> /app/start.sh && \
    echo '  if curl -s http://localhost:${SERVER_PORT:-8080}/actuator/health > /dev/null 2>&1; then' >> /app/start.sh && \
    echo '    echo "Application started successfully"' >> /app/start.sh && \
    echo '    break' >> /app/start.sh && \
    echo '  fi' >> /app/start.sh && \
    echo '  echo "Waiting... ($i/60)"' >> /app/start.sh && \
    echo '  sleep 2' >> /app/start.sh && \
    echo 'done' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo '# Start the RunPod handler' >> /app/start.sh && \
    echo 'python3 handler.py' >> /app/start.sh && \
    chmod +x /app/start.sh

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:${SERVER_PORT:-8080}/actuator/health || exit 1

# Run the startup script
CMD ["/app/start.sh"]
