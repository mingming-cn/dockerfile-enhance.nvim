# 多阶段构建示例 Dockerfile
FROM node:18-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# 开发环境
FROM base AS development
RUN npm ci
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]

# 测试环境
FROM base AS test
RUN npm ci
COPY . .
RUN npm run test

# 生产环境
FROM base AS production
COPY . .
RUN npm run build
EXPOSE 8080
CMD ["npm", "start"]

# 最小化生产镜像
FROM node:18-alpine AS production-minimal
WORKDIR /app
COPY --from=production /app/dist ./dist
COPY --from=production /app/package*.json ./
RUN npm ci --only=production
EXPOSE 8080
CMD ["npm", "start"] 