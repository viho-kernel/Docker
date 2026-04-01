FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY  . .

FROM node:18-alpine

WORKDIR /app

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
COPY --from=builder /app/node_modules ./node_modules

USER nodejs

EXPOSE 5000

CMD ["node", "server.js"]