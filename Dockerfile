# syntax=docker/dockerfile:1

FROM gradle:8.14.3-jdk21 AS build
WORKDIR /workspace

COPY --chown=gradle:gradle gradle gradle
COPY --chown=gradle:gradle gradlew gradlew
COPY --chown=gradle:gradle gradle.properties settings.gradle.kts build.gradle.kts ./
COPY --chown=gradle:gradle src src

RUN ./gradlew buildFatJar --no-daemon

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

RUN addgroup -S virtualadserver && adduser -S virtualadserver -G virtualadserver

COPY --from=build /workspace/build/libs/VirtualAdServer-all.jar /app/VirtualAdServer.jar

RUN mkdir -p /app/adPool && chown -R virtualadserver:virtualadserver /app

USER virtualadserver
EXPOSE 8080
VOLUME ["/app/adPool"]

ENTRYPOINT ["java", "-jar", "/app/VirtualAdServer.jar"]
