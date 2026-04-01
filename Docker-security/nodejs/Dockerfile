FROM node:latest

RUN groupadd -r nonroot && useradd -r -g nonroot nonroot
WORKDIR /app

COPY package*.json .

RUN npm install

COPY *.js .

USER nonroot

EXPOSE 3000

CMD ["npm", "start"]