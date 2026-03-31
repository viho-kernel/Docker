FROM eclipse-temurin:17-jdk


WORKDIR /app

COPY App.java .

# Compile Java file
RUN javac App.java

# Run compiled class
CMD ["java", "App"]
