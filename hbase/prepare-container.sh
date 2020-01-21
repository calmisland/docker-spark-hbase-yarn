#!/bin/sh -x
  
. /build/config-hbase.sh

apt-get update -y
apt-get install $minimal_apt_get_args
