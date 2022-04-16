FROM ubuntu:20.04

RUN mkdir /opt/tomcat/ && apt update && apt install -y curl ssh vim wget tar gzip default-jre default-jdk &&  java -version && javac -version

WORKDIR /opt/tomcat
RUN curl -O https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.77/bin/apache-tomcat-8.5.77.tar.gz && \
    tar xvf apache*.tar.gz && \
    mv apache-tomcat-8.5.77/* /opt/tomcat/.  

WORKDIR /opt/tomcat/webapps
RUN curl -O -L https://github.com/AKSarav/SampleWebApp/raw/master/dist/SampleWebApp.war

EXPOSE 8080

CMD exec /bin/bash -c "/opt/tomcat/bin/catalina.sh run && trap : TERM INT; sleep infinity & wait"