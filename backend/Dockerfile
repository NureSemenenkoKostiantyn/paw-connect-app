FROM maven:3.9.9-amazoncorretto-21-al2023 AS build
WORKDIR /app
COPY pom.xml ./
COPY src ./src/
RUN mvn clean package -DskipTests


# Use a lightweight JDK image
FROM eclipse-temurin:21-jdk-alpine

# Set the working directory
WORKDIR /app

# Copy Maven build artifact
COPY --from=build /app/target/*.jar ./app.jar

# Expose port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
