FROM node:latest AS Builder

RUN groupadd -r nonroot && useradd -r -g nonroot nonroot
WORKDIR /app
COPY package*.json .
RUN npm install

COPY *.js .

USER nonroot

FROM node:25-slim

WORKDIR /app

COPY --from=Builder /app/node_modules ./node_modules
COPY /app/*.js ./app.js 

EXPOSE 3000

CMD ["node", "app.js"]