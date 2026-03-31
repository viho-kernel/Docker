FROM openjdk:17-slim

WORKDIR /app

COPY src ./src
COPY pom.xml .

RUN ./mvnw package -DskipTests

CMD ["java", "-jar", "target/my-java-app-1.0-SNAPSHOT.jar"]