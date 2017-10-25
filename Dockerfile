FROM maven:3.2-jdk-8-onbuild

EXPOSE 8080
CMD ["mvn", "spring-boot:run"]
