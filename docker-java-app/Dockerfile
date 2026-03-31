FROM ubuntu:latest AS build

WORKDIR /app

COPY . /app

RUN mvn clean package 

FROM openjdk:17

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

CMD [ "java", "-jar", "app.jar" ]
