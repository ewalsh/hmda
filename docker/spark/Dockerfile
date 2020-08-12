FROM ubuntu:bionic
MAINTAINER ewalsh200 <ewalsh@economicdatasciences.ai>

WORKDIR /opt

RUN apt-get clean
RUN apt-get -o Acquire::Check-Valid-Until=false update -y --fix-missing
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
RUN apt-get install -y --fix-missing apt-utils iputils-ping nano zip python3 curl wget r-base

RUN wget https://archive.apache.org/dist/spark/spark-3.0.0/spark-3.0.0-bin-hadoop2.7.tgz
RUN tar -xzf spark-3.0.0-bin-hadoop2.7.tgz
RUN wget https://econdatasci.s3.eu-west-2.amazonaws.com/dev/jdk-8u231-linux-x64.tar.gz
RUN tar -xzf jdk-8u231-linux-x64.tar.gz

ENV SPARK_HOME=/opt/spark-2.2.1-bin-hadoop2.7
ENV PATH=$PATH:$SPARK_HOME/bin
ENV JAVA_HOME=/opt/jdk1.8.0_231
ENV PATH=$PATH:$JAVA_HOME/bin

RUN addgroup hadoop
RUN useradd -ms /bin/bash hduser
RUN usermod -a -G hadoop hduser
RUN chown -R hduser:hadoop /opt/spark-3.0.0-bin-hadoop2.7

USER hduser

EXPOSE 8080 8081 7077

WORKDIR /opt/spark-3.0.0-bin-hadoop2.7

## CMD ./bin/spark-class org.apache.spark.deploy.master.Master
CMD ["/bin/sh" "-c" "./bin/spark-class org.apache.spark.deploy.worker.Worker 172.29.0.4:7077"]
