# Use the official Gradle image to build the project
FROM gradle:8-jdk21 AS build
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
RUN ./gradlew buildFatJar --no-daemon

# Use a lightweight JRE image for the runtime
FROM eclipse-temurin:21-jre-alpine

# Expose the port the app runs on
EXPOSE 8080

# Create and set the working directory
WORKDIR /app

# Copy the fat JAR from the build stage
COPY --from=build /home/gradle/src/build/libs/VirtualAdServer-all.jar /app/VirtualAdServer.jar

# Copy the initial adPool directory to the volume location
COPY adPool /adPool

# Define /adPool as a volume to make it accessible from outside
VOLUME /adPool

# Create a symbolic link so the application can access the volume at the expected relative path
RUN ln -s /adPool /app/adPool

# Run the application
ENTRYPOINT ["java", "-jar", "/app/VirtualAdServer.jar"]
