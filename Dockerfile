FROM maven:latest-onbuild

EXPOSE 8080
CMD ["mvn", "spring-boot:run"]
