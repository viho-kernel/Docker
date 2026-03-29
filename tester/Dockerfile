FROM node:18-alpine AS builder

WORKDIR /app

COPY . .

RUN npm install && npm run build

FROM nginx:alpine-slim

COPY --from=builder /app/dest /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/custom.conf

EXPOSE 80 8080 8081
