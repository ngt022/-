# 火之文明 - Node.js 应用 Dockerfile
FROM node:22-slim

WORKDIR /app

# 只复制 package 文件先装依赖（利用缓存）
COPY server/package*.json ./server/
RUN cd server && npm ci --omit=dev 2>/dev/null || npm install --omit=dev

# 复制服务端代码
COPY server/ ./server/

# 复制前端构建产物（由 docker-compose 挂载覆盖）
COPY docs/ ./docs/

EXPOSE 3007

WORKDIR /app/server
CMD ["node", "--experimental-modules", "index.js"]
