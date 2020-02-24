#!/bin/bash
set -euxo pipefail

# Prevent initramfs updates from trying to run grub and lilo.
export INITRD=no
export DEBIAN_FRONTEND=noninteractive
export JAVA_HOME=/opt/java/openjdk

minimal_apt_get_args='-y --no-install-recommends'


## Build time dependencies ##
HBASE_BUILD_PACKAGES="curl"

# Core list from docs
#HBASE_BUILD_PACKAGES="$HBASE_BUILD_PACKAGES "

HBASE_HOME=/opt/hbase
# HOSTNAME=dmhadoop
NAMENODE_PORT=8020
