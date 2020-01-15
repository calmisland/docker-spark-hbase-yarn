#!/bin/sh -x

. /build/config-hbase.sh

apt-get update -y

apt-get install $minimal_apt_get_args $HBASE_BUILD_PACKAGES

cd /opt

mv /opt/hbase-1.4.10 /opt/hbase

sed -i 's/HOSTNAME/'"$HOSTNAME"'/' /opt/hbase/conf/hbase-site.xml
sed -i 's/HOSTNAME/'"$HOSTNAME"'/' /opt/hbase/conf/zoo.cfg
sed -i 's/localhost/'"$HOSTNAME"'/' /opt/hbase/conf/regionservers
sed -i s/NAMENODE_PORT/$NAMENODE_PORT/ /opt/hbase/conf/hbase-site.xml
