FROM node:18

WORKDIR /app

#Copt package.json for cache optimization
COPY package*.json ./

#Instasll necessary dependences
RUN npm install


#copt everything to the /app directory including the application file
COPY . .

EXPOSE 3000

#RUNNING APP SERVER

CMD [ "node", "app.js" ]