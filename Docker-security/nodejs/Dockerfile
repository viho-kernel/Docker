FROM node:latest AS Builder

#RUN groupadd -r nonroot && useradd -r -g nonroot nonroot
WORKDIR /app
COPY package*.json .
RUN npm install

COPY *.js .

#USER nonroot

FROM gcr.io/distroless/nodejs22-debian13

WORKDIR /app

COPY --from=Builder /app/node_modules ./node_modules
COPY --from=Builder /app/*.js ./app.js 

EXPOSE 3000

CMD ["node", "app.js"]