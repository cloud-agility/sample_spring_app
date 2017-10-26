FROM maven:3.5.0-jdk-8-onbuild

EXPOSE 8080
CMD ["mvn", "spring-boot:run"]
