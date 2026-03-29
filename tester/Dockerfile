# Stage 1: Build
FROM node:18-alpine AS builder
WORKDIR /app
COPY . .
RUN npm install && npm run build

# Stage 2: Runtime
FROM nginx:alpine-slim
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/custom.conf
EXPOSE 80