FROM openjdk:11.0.6-slim

MAINTAINER  Tvrtko Mrkonjić <author@email.com>

WORKDIR /app

COPY . /app

CMD ["mvn", "liberty:run"]

