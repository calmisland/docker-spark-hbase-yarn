#!/bin/bash
set -euxo pipefail
source /build/config-hbase.sh

here=$(pwd)

# delete files that are not needed to run hbase
rm -rf docs *.txt LEGAL
rm -f */*.cmd

# Set Java home for hbase servers
sed -i "s,^. export JAVA_HOME.*,export JAVA_HOME=$JAVA_HOME," $HBASE_HOME/conf/hbase-env.sh

sed -i 's/HOSTNAME/'"$HOSTNAME"'/' $HBASE_HOME/conf/hbase-site-standalone.xml
sed -i 's/HOSTNAME/'"$HOSTNAME"'/' $HBASE_HOME/conf/hbase-site-pesudo-distributed.xml

sed -i 's/HOSTNAME/'"$HOSTNAME"'/' $HBASE_HOME/conf/zoo.cfg
sed -i 's/localhost/'"$HOSTNAME"'/' $HBASE_HOME/conf/regionservers
sed -i s/NAMENODE_PORT/$NAMENODE_PORT/ $HBASE_HOME/conf/hbase-site-standalone.xml
sed -i s/NAMENODE_PORT/$NAMENODE_PORT/ $HBASE_HOME/conf/hbase-site-pesudo-distributed.xml
cat $HBASE_HOME/conf/hbase-site-standalone.xml > $HBASE_HOME/conf/hbase-site.xml

# Set interactive shell defaults
cat > /etc/profile.d/defaults.sh <<EOF
JAVA_HOME=$JAVA_HOME
export JAVA_HOME
EOF

cd /usr/bin
ln -sf $here/bin/* .
