FROM ubuntu:latest AS build

WORKDIR /app

COPY . /app

RUN apt-get update && apt-get install -y maven openjdk-17-jdk && rm -rf /var/lib/apt/lists/*

RUN mvn clean package

FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

CMD [ "java", "-jar", "app.jar" ]
