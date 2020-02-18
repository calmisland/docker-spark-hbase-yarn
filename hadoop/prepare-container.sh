#!/bin/bash
set -euxo pipefail

source /build/config-hdfs.sh

apt-get clean && rm -rf /var/lib/apt/lists/* && apt-get update
apt-get install -y curl tar sudo openssh-server openssh-client rsync