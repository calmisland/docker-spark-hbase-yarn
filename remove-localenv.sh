#!/bin/bash
#
# Script to start docker and update the /etc/hosts file to point to
# the hbase-docker container
#
# set -x

set -euxo pipefail
source static-info.sh

if [ -z "${DOCKER_MACHINE_NAME}" ]
then
	echo "No exist"
	exit 1
fi

docker-machine rm ${DOCKER_MACHINE_NAME}

declare -a DOCKER_CONTAINERS=(
	${HDFS_CONTAINER}
	${HBASE_CONTAINER}
	${YARN_CONTAINER}
	${DOCKER_MACHINE_NAME}
	)

for DOCKER_CONTAINER in "${DOCKER_CONTAINERS[@]}"
do
    IP=$(docker-machine ip ${DOCKER_MACHINE_NAME})

    echo "Deleting ${DOCKER_CONTAINER} entry from local /etc/hosts"
    if grep "${DOCKER_CONTAINER}" /etc/hosts >/dev/null; then
      sudo sed -i '' "s/^.*${DOCKER_CONTAINER}.*\$//" /etc/hosts
    fi

done


cp ~/.ssh/known_hosts ~/.ssh/known_hosts.bak

cp ~/.ssh/known_hosts ~/.ssh/known_hosts.bak
grep -v "${DOCKER_MACHINE_NAME}" ~/.ssh/known_hosts > ~/.ssh/known_hosts_new
mv ~/.ssh/known_hosts_new ~/.ssh/known_hosts

echo "Local /etc/hosts cleansed!"
