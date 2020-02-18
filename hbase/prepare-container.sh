#!/bin/bash
set -euxo pipefail

source /build/config-hbase.sh

apt-get update -y
apt-get install $minimal_apt_get_args

ln -s /opt/hbase-1.4.10 /opt/hbase