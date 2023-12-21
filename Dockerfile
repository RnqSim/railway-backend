FROM maven:3.8.3-openjdk-17 AS build

WORKDIR /app

COPY pom.xml .

COPY src ./src

RUN mvn clean package

FROM adoptopenjdk:17-jre-hotspot

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
