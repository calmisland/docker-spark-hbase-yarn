# HBase in Docker
#
# Version 0.3

# http://docs.docker.io/en/latest/use/builder/

FROM adoptopenjdk/openjdk8:jdk8u222-b10 

COPY *.sh /build/
COPY wait_for_it.sh /
ADD hbase-1.4.10-bin.tar.gz /opt

RUN /build/prepare-container.sh

ADD hbase-site-*.xml /opt/hbase/conf/
ADD zoo.cfg /opt/hbase/conf/zoo.cfg
ADD hbase-server /opt/hbase-server 

RUN /build/build-hbase.sh && /build/cleanup-hbase.sh && rm -rf /build

VOLUME /data


# HBase's zookeeper - used to find servers
EXPOSE 2181

## HBase Master API port
EXPOSE 16000
# HBase Master web UI at :15010/master-status;  ZK at :16010/zk.jsp
EXPOSE 16010
# Region server API port
EXPOSE 16020
# HBase Region server web UI at :16030/rs-status
EXPOSE 16030

CMD ["/opt/hbase-server"]
