FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY  . .

FROM node:18-alpine

WORKDIR /app

RUN groupadd -r nonroot && useradd -r -g nonroot nonroot

COPY --from=builder /app/node_modules ./node_modules

USER nonroot

EXPOSE 5000

CMD ["node", "server.js"]