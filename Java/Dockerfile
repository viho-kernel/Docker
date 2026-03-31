FROM openjdk:17-slim

WORKDIR /app

COPY App.java .

# Compile Java file
RUN javac App.java

# Run compiled class
CMD ["java", "App"]
