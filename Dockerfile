# Updated Dockerfile content
# ... other lines ...

# Update Maven repository configurations
# Replace lines 24-27
<repository>
    <id>aliyunmaven</id>
    <name>阿里云公共仓库</name>
    <url>https://maven.aliyun.com/repository/public</url>
    <mirrors>
        <mirror>
            <id>aliyunmaven</id>
            <mirrorOf>*</mirrorOf>
            <url>https://maven.aliyun.com/repository/public</url>
        </mirror>
    </mirrors>
</repository>

# Remove line 41
# Removed mvn dependency:go-offline ...
# ... other lines ...
