FROM maven:latest
COPY ./application/ /application/
WORKDIR /application

EXPOSE 8080
CMD ["mvn", "spring-boot:run"]