FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build

FROM nginx:alpine

WORKDIR /app


COPY --from=builder /app/build ./build

EXPOSE 3000

CMD [ "serve", "-s", "build", "-l", "3000" ]