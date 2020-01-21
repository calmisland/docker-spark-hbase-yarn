#!/bin/sh -x

. /build/config-hbase.sh

here=$(pwd)

# delete files that are not needed to run hbase
rm -rf docs *.txt LEGAL
rm -f */*.cmd

# Set Java home for hbase servers
sed -i "s,^. export JAVA_HOME.*,export JAVA_HOME=$JAVA_HOME," conf/hbase-env.sh
sed -i 's/HOSTNAME/'"$HOSTNAME"'/' /opt/hbase/conf/hbase-site.xml
sed -i 's/HOSTNAME/'"$HOSTNAME"'/' /opt/hbase/conf/zoo.cfg
sed -i 's/localhost/'"$HOSTNAME"'/' /opt/hbase/conf/regionservers
sed -i s/NAMENODE_PORT/$NAMENODE_PORT/ /opt/hbase/conf/hbase-site.xml
sed -i s/NAMENODE_PORT/$NAMENODE_PORT/ /opt/hbase/conf/hbase-site-pesudo-distributed.xml

# Set interactive shell defaults
cat > /etc/profile.d/defaults.sh <<EOF
JAVA_HOME=$JAVA_HOME
export JAVA_HOME
EOF

cd /usr/bin
ln -sf $here/bin/* .
