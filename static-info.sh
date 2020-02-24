#!/bin/bash

IP='192.168.99.106'
BROADCAST_RANGE='192.168.99.255'
HDFS_CONTAINER="hdfs-master"
HBASE_CONTAINER="hbase-master"
YARN_CONTAINER="yarn-master"

DOCKER_MACHINE_NAME='datapipeline'
DOCKER_MACHINE_DEFAULT_PASSWORD=tcuser

RESOURCE_BUCKET=s3://data-collection-code-artifacts/data-pipeline
SPARK_TGZ=spark-2.4.4-bin-without-hadoop.tgz
HADOOP_TGZ=hadoop-2.8.5.tar.gz
HBASE_TGZ=hbase-1.4.10-bin.tar.gz


