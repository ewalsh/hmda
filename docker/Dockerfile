FROM ubuntu:bionic
MAINTAINER ewalsh200 <ewalsh@economicdatasciences.ai>

WORKDIR /opt

RUN apt-get clean
RUN apt-get update -y --fix-missing
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
RUN apt-get install -y apt-utils iputils-ping nano zip python3 curl wget r-base gdebi-core

RUN wget https://download2.rstudio.org/server/trusty/amd64/rstudio-server-1.2.5042-amd64.deb
RUN gdebi rstudio-server-1.2.5042-amd64.deb
RUN wget https://archive.apache.org/dist/spark/spark-2.2.1/spark-2.2.1-bin-hadoop2.7.tgz
RUN tar -xzf spark-2.2.1-bin-hadoop2.7.tgz
RUN wget https://econdatasci.s3.eu-west-2.amazonaws.com/dev/jdk-8u231-linux-x64.tar.gz
RUN tar -xzf jdk-8u231-linux-x64.tar.gz

ENV SPARK_HOME=/opt/spark-2.2.1-bin-hadoop2.7
ENV PATH=$PATH:$SPARK_HOME/bin
ENV JAVA_HOME=/opt/jdk1.8.0_231
ENV PATH=$PATH:/JAVA_HOME/bin

RUN addgroup hadoop
RUN useradd -ms /bin/bash hduser
RUN usermod -a -G hadoop hduser
RUN chown -R hduser:hadoop /opt/spark-2.2.1-bin-hadoop2.7


USER hduser

EXPOSE 8080 8081 7077 8787

WORKDIR /opt/spark-2.2.1-bin-hadoop2.7

CMD ./bin/spark-class org.apache.spark.deploy.master.Master
