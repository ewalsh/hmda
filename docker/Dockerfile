FROM ubuntu:bionic

WORKDIR /opt

RUN apt-get clean
RUN apt-get update -y --fix-missing
RUN apt-get install -y nano zip python3 curl apt-utils iputils-ping openjdk-8-jdk wget

RUN wget https://archive.apache.org/dist/spark/spark-2.2.1/spark-2.2.1-bin-hadoop2.7.tgz
RUN tar -xzf spark-2.2.1-bin-hadoop2.7.tgz

RUN addgroup hadoop
RUN useradd -ms /bin/bash hduser
RUN usermod -a -G hadoop hduser
RUN chown -R hduser:hadoop /opt/spark-2.2.1-bin-hadoop2.7

ENV SPARK_HOME /opt/spark-2.2.1-bin-hadoop2.7
ENV PATH=$PATH:$SPARK_HOME/bin

USER hduser

EXPOSE 8080 8081 7077

WORKDIR /opt/spark-2.2.1-bin-hadoop2.7
