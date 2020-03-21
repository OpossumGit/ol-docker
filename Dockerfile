FROM openjdk:11.0.6-slim

LABEL maintainer="Tvrtko Mrkonjić" \
description="BASED ON https://github.com/carlossg/docker-maven/tree/master/jdk-8-slim"\
io.k8s.description="Gets maven. Takes source code. Packages during build. Runs liberty:run" \
io.k8s.display-name="OpenLiberty app" \
io.openshift.expose-services="9080:http" \
io.openshift.tags="openliberty"

ARG MAVEN_VERSION=3.6.3
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

WORKDIR /app
COPY . /app

EXPOSE 9080

RUN echo '<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd"><localRepository>/app/repository</localRepository></settings>' >  settings-docker.xml && \
  mkdir /app/repository && \
  mvn -s settings-docker.xml package && \
  mvn -s settings-docker.xml liberty:create && \
  mvn -s settings-docker.xml liberty:install-feature && \
  mvn -s settings-docker.xml liberty:deploy && \
  chgrp -R 0 /app && \
  chmod -R g=u /app

USER 1001

CMD ["mvn", "-s", "settings-docker.xml", "liberty:run"]

