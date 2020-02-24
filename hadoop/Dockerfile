# Creates pseudo distributed hadoop 2.6.0 on Ubuntu 14.04
#
# docker build -t sequenceiq/hadoop-ubuntu:2.6.0 .

FROM adoptopenjdk/openjdk8:jdk8u222-b10
USER root

ENV JAVA_HOME /opt/java/openjdk
ENV PATH $PATH:$JAVA_HOME/bin
ENV HADOOP_PREFIX /usr/local/hadoop
ENV SPARK_HOME /usr/local/spark
ENV BOOTSTRAP /etc/bootstrap.sh

ADD hadoop-2.8.5.tar.gz /usr/local/
ADD *.xml /usr/local/hadoop-2.8.5/etc/hadoop/
ADD *.xml.template /usr/local/hadoop-2.8.5/etc/hadoop/
ADD spark-2.4.4-bin-without-hadoop.tgz /usr/local/
ADD bootstrap.sh /etc/bootstrap.sh
COPY *.sh /build/

RUN /build/prepare-container.sh
ADD ssh_config /root/.ssh/config
RUN /build/prepare-hdfs.sh

CMD ["/etc/bootstrap.sh", "-d"]

EXPOSE 50020 50090 50070 50010 50075 8031 8032 8033 8040 8042 49707 22 8088 8030 8020
