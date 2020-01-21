#!/bin/bash
#
# Script to start docker and update the /etc/hosts file to point to
# the hbase-docker container
#
# set -x

if [ -z "${DOCKER_MACHINE_NAME}" ]
then
	echo "No exist"
	exit 1
fi

LOCAL_VM_NAME=${DOCKER_MACHINE_NAME}

declare -a DOCKER_CONTAINERS=(
"hdfs-master"
"hbase-master"
"yarn-master"
${LOCAL_VM_NAME}
)

for DOCKER_CONTAINER in "${DOCKER_CONTAINERS[@]}"
do
    IP=$(docker-machine ip ${LOCAL_VM_NAME})

    echo "Deleting ${DOCKER_CONTAINER} entry from local /etc/hosts"
    if grep "${DOCKER_CONTAINER}" /etc/hosts >/dev/null; then
      sudo sed -i '' "s/^.*${DOCKER_CONTAINER}.*\$//" /etc/hosts
    fi

done


cp ~/.ssh/known_hosts ~/.ssh/known_hosts.bak
grep -v "${LOCAL_VM_NAME}" ~/.ssh/known_hosts > ~/.ssh/known_hosts_new
mv ~/.ssh/known_hosts_new ~/.ssh/known_hosts

echo "Local /etc/hosts cleansed!"
