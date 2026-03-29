# Stage 1: "builder" (just holds files)
FROM alpine:latest AS builder
WORKDIR /app
COPY . .

# Stage 2: Runtime
FROM nginx:alpine-slim
COPY --from=builder /app /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
