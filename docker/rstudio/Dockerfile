FROM ubuntu:bionic
MAINTAINER ewalsh200 <ewalsh@economicdatasciences.ai>

WORKDIR /opt

RUN apt-get clean
RUN apt-get update -y --fix-missing
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
RUN apt-get install -y apt-utils iputils-ping nano zip python3 curl wget r-base gdebi-core
RUN apt-get install -y lib32gcc1 lib32stdc++6 libc6-i386 libclang-6.0-dev libclang-common-6.0-dev
RUN apt-get install -y libclang-dev libclang1-6.0 libgc1c2 libllvm6.0 libobjc-7-dev libobjc4 psmisc sudo
RUN apt-get install -y libssl1.0.0 libssl-dev dpkg

RUN wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.2.5042-amd64.deb
RUN gdebi --n rstudio-server-1.2.5042-amd64.deb
RUN wget https://archive.apache.org/dist/spark/spark-2.2.1/spark-2.2.1-bin-hadoop2.7.tgz
RUN tar -xzf spark-2.2.1-bin-hadoop2.7.tgz
RUN wget https://econdatasci.s3.eu-west-2.amazonaws.com/dev/jdk-8u231-linux-x64.tar.gz
RUN tar -xzf jdk-8u231-linux-x64.tar.gz

ENV SPARK_HOME=/opt/spark-2.2.1-bin-hadoop2.7
ENV PATH=$PATH:$SPARK_HOME/bin
ENV JAVA_HOME=/opt/jdk1.8.0_231
ENV PATH=$PATH:/JAVA_HOME/bin

RUN addgroup hadoop \
&& useradd hduser \
&& echo "hduser:edsAnalytics1" | chpasswd \
&& usermod -a -G hadoop hduser \
&& mkdir /home/hduser \
&& chown hduser:hadoop /home/hduser \
&& chown -R hduser:hadoop /opt/spark-2.2.1-bin-hadoop2.7

USER hduser

EXPOSE 8787

WORKDIR /opt/spark-2.2.1-bin-hadoop2.7

CMD ["rstudio-server","start"]
