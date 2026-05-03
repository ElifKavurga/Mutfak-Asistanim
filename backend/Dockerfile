FROM maven:3.9.11-eclipse-temurin-17 AS build

WORKDIR /app

COPY pom.xml ./
RUN mvn -q -Dmaven.test.skip=true dependency:go-offline

COPY src ./src
RUN mvn -q -Dmaven.test.skip=true package

FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

COPY --from=build /app/target/*.jar /app/app.jar

ENV PORT=8080

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
