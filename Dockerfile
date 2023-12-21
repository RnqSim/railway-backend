#Use Maven base image 
FROM maven-3.8.3-openjdk-17 AS builder
COPY src /home/app/src
COPY pom.xml /home/app
#Build an uber jar
RUN mvn -f /home/app/pom.xml package
WORKDIR /home/app/target
#Extract the uber jar into layers
RUN java -Djarmode=layertools -jar /home/app/target/*.jar extract

#STAGE 2 - Use the layered jar to run Spring Boot app
#Use OpenJDK17 base image
FROM openjdk:17-alpine
USER root
#Copy individual layers one by one 
COPY --from=builder /home/app/target/dependencies/ ./
#Add this to fix a bug which happens during sequential copy commands
RUN true
COPY --from=builder /home/app/target/spring-boot-loader/ ./
RUN true
COPY --from=builder /home/app/target/snapshot-dependencies/ ./
RUN true
COPY --from=builder /home/app/target/custom-dependencies/ ./
RUN true
COPY --from=builder /home/app/target/application/ ./
#Expose port on which Spring Boot app will run
EXPOSE 8080
#Switch to non root user
USER 1001
#Start Spring Boot app
ENTRYPOINT ["java","org.springframework.boot.loader.JarLauncher"]