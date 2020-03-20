FROM openjdk:11.0.6-slim

MAINTAINER  Tvrtko Mrkonjić <author@email.com>
# BASED ON https://github.com/carlossg/docker-maven/tree/master/jdk-8-slim

# Labels consumed by OpenShift
LABEL io.k8s.description="Gets maven. Takes source code. Packages during build. Runs liberty:run" \
io.k8s.display-name="OpenLiberty app" \
io.openshift.expose-services="9080:http" \
io.openshift.tags="openliberty"


ARG MAVEN_VERSION=3.6.3
ARG USER_HOME_DIR="/root"
ARG SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN apt-get update && \
    apt-get install -y \
      curl procps \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"


WORKDIR /app

COPY . /app

EXPOSE 9080

RUN mkdir -p /.m2/repository && \
  chgrp -R 0 /.m2/repository /app/target && \
  chmod -R g=u /.m2/repository /app/target

USER 1001

RUN ["mvn", "package"]

CMD ["mvn", "liberty:run"]

