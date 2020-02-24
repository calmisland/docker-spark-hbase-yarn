#!/bin/bash
set -euxo pipefail

source /build/config-hdfs.sh

cd /usr/local/hadoop-2.8.5 && cd /usr/local/spark-2.4.4-bin-without-hadoop
ln -s /usr/local/hadoop-2.8.5 $HADOOP_PREFIX
ln -s /usr/local/spark-2.4.4-bin-without-hadoop  $SPARK_HOME

# passwordless ssh
rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa
ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
chmod 600 /root/.ssh/config
sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config
echo "UsePAM no" >> /etc/ssh/sshd_config
echo "Port 2122" >> /etc/ssh/sshd_config
chown root:root /root/.ssh/config


sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/opt/java/openjdk\nexport HADOOP_PREFIX='$HADOOP_PREFIX'\nexport HADOOP_HOME='$HADOOP_PREFIX'\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR='$HADOOP_PREFIX'/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

cat $HADOOP_PREFIX/etc/hadoop/core-site.xml.template > $HADOOP_PREFIX/etc/hadoop/core-site.xml
sed -i s/HOSTNAME/localhost/ $HADOOP_PREFIX/etc/hadoop/core-site.xml
sed -i s/NAMENODE_PORT/$NAMENODE_PORT/ $HADOOP_PREFIX/etc/hadoop/core-site.xml

mkdir $HADOOP_PREFIX/input
cp $HADOOP_PREFIX/etc/hadoop/*.xml $HADOOP_PREFIX/input

# workingaround docker.io build error
ls -la $HADOOP_PREFIX/etc/hadoop/*-env.sh
chmod +x $HADOOP_PREFIX/etc/hadoop/*-env.sh
ls -la $HADOOP_PREFIX/etc/hadoop/*-env.sh


$HADOOP_PREFIX/bin/hdfs namenode -format

chown root:root /etc/bootstrap.sh
chmod 700 /etc/bootstrap.sh


# fix the 254 error code
service ssh start && $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && $HADOOP_PREFIX/sbin/start-dfs.sh && $HADOOP_PREFIX/bin/hdfs dfs -mkdir -p /user/root
service ssh start && $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && $HADOOP_PREFIX/sbin/start-dfs.sh && $HADOOP_PREFIX/bin/hdfs dfs -put $HADOOP_PREFIX/etc/hadoop/ input


echo "export SPARK_DIST_CLASSPATH=$($HADOOP_PREFIX/bin/hadoop classpath)" >> $SPARK_HOME/conf/spark-env.sh
echo "export SPARK_LOCAL_IP=127.0.0.1" >> $SPARK_HOME/bin/load-spark-env.sh
chmod +x $SPARK_HOME/conf/spark-env.sh

# fixing the libhadoop.so like a boss
# rm -rf /usr/local/hadoop/lib/native/*
# curl -Ls http://dl.bintray.com/sequenceiq/sequenceiq-bin/hadoop-native-64-2.6.0.tar|tar -x -C /usr/local/hadoop/lib/native/


# # installing supervisord
# yum install -y python-setuptools
# easy_install pip
# curl https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -o - | python
# pip install supervisor
#
# ADD supervisord.conf /etc/supervisord.conf

