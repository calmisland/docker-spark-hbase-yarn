#!/bin/bash
set -euxo pipefail
source static-info.sh

config_vm_ip() {
	echo "ifconfig eth1 $IP netmask 255.255.255.0 broadcast $BROADCAST_RANGE up" | docker-machine ssh `echo $DOCKER_MACHINE_NAME` sudo tee /var/lib/boot2docker/bootsync.sh > /dev/null
	docker-machine restart `echo $DOCKER_MACHINE_NAME`
	docker-machine regenerate-certs -f "${DOCKER_MACHINE_NAME}"
	docker-machine env "${DOCKER_MACHINE_NAME}"
}


set_local_network() {
	declare -a DOCKER_CONTAINERS=(
	${HDFS_CONTAINER}
	${HBASE_CONTAINER}
	${YARN_CONTAINER}
	${DOCKER_MACHINE_NAME}
	)

	for DOCKER_CONTAINER in "${DOCKER_CONTAINERS[@]}"
	do
		IP=$(docker-machine ip ${DOCKER_MACHINE_NAME})

		echo "Updating /etc/hosts to make ${DOCKER_CONTAINER} point to ${IP} locally"
		if grep "${DOCKER_CONTAINER}" /etc/hosts >/dev/null; then
		sudo sed -i '' "s/^.*${DOCKER_CONTAINER}.*\$/${IP} ${DOCKER_CONTAINER}/" /etc/hosts
		else
		sudo sh -c "echo '${IP} ${DOCKER_CONTAINER}' >> /etc/hosts"
		fi

	done

	echo "Updating /etc/hosts to make ${HBASE_CONTAINER} point to ${IP} in docker-machine"
	ETC_HOST_LOCALHOST_LINE="127.0.0.1 localhost localhost.local"
	REGEX_ETC_HOST_LOCALHOST_LINE="^.*127.0.0.1.*\$"
	if docker-machine ssh "${DOCKER_MACHINE_NAME}" "grep '${HBASE_CONTAINER}' /etc/hosts >/dev/null"; then
	eval $(docker-machine ssh "${DOCKER_MACHINE_NAME}" "sudo sed -i 's/^.*${HBASE_CONTAINER}.*\$/${IP} ${HBASE_CONTAINER} ${DOCKER_MACHINE_NAME}/' /etc/hosts")
	eval $(docker-machine ssh "${DOCKER_MACHINE_NAME}" "sudo sed -i 's/${REGEX_ETC_HOST_LOCALHOST_LINE}/${ETC_HOST_LOCALHOST_LINE}/' /etc/hosts")
	else
	docker-machine ssh "${DOCKER_MACHINE_NAME}" "sudo sh -c \"echo '${IP} ${HBASE_CONTAINER} ${DOCKER_MACHINE_NAME}' >> /etc/hosts\""
	docker-machine ssh "${DOCKER_MACHINE_NAME}" "sudo sed -i 's/${REGEX_ETC_HOST_LOCALHOST_LINE}/${ETC_HOST_LOCALHOST_LINE}/' /etc/hosts"
	fi

}

set_hbase_hostname() {
	sed 's/^.* HOSTNAME.*/HOSTNAME='"$DOCKER_MACHINE_NAME"'/' ./hbase/config-hbase-template.sh > ./hbase/config-hbase.sh
}

copy_build_resources() {
	cp ./resources/$SPARK_TGZ ./hadoop/$SPARK_TGZ
    cp ./resources/$HADOOP_TGZ ./hadoop/$HADOOP_TGZ
	cp ./resources/$HBASE_TGZ ./hbase/$HBASE_TGZ
}

allow_vm_machine_assessment() {
	echo
	echo
	echo "Register ssh connection to the docker-machine ${DOCKER_MACHINE_NAME}"
	echo "Step1. Register in ssh-connection by Yes"
	echo "Step2. Insert 'tcuser', the default password of the docker-machine"
	echo "Step3. Insert 'exit' after succeeding to join the docker-machine"
	echo
	echo

 	ssh docker@"${DOCKER_MACHINE_NAME}"
}



main() {

	docker-machine create -d virtualbox --virtualbox-memory "4096" $DOCKER_MACHINE_NAME

	echo "Inject a static ip:${IP} to docker-machine"
	config_vm_ip

	echo "Set IP for containers on the local machine"
	set_local_network

	echo "Set hostname for HBase"
	set_hbase_hostname

	echo "Copy Build Resources"
	copy_build_resources

	echo "Allow Access to Docker Machine"
	allow_vm_machine_assessment
}

main "$@"