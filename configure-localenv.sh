
config_vm_ip() {
	echo "ifconfig eth1 192.168.99.50 netmask 255.255.255.0 broadcast 192.168.99.255 up" | docker-machine ssh `echo $LOCAL_VM_NAME` sudo tee /var/lib/boot2docker/bootsync.sh > /dev/null
	docker-machine restart `echo $LOCAL_VM_NAME`
}


set_local_network() {
	declare -a DOCKER_CONTAINERS=(
	"hdfs-master"
	"hbase-master"
	"yarn-master"
	${LOCAL_VM_NAME}
	)

	for DOCKER_CONTAINER in "${DOCKER_CONTAINERS[@]}"
	do
		IP=$(docker-machine ip ${LOCAL_VM_NAME})

		echo "Updating /etc/hosts to make ${DOCKER_CONTAINER} point to ${IP} locally"
		if grep "${DOCKER_CONTAINER}" /etc/hosts >/dev/null; then
		sudo sed -i '' "s/^.*${DOCKER_CONTAINER}.*\$/${IP} ${DOCKER_CONTAINER}/" /etc/hosts
		else
		sudo sh -c "echo '${IP} ${DOCKER_CONTAINER}' >> /etc/hosts"
		fi

	done

	DOCKER_CONTAINER="hbase-master"

	echo "Updating /etc/hosts to make ${DOCKER_CONTAINER} point to ${IP} in docker-machine"
	ETC_HOST_LOCALHOST_LINE="127.0.0.1 localhost localhost.local"
	REGEX_ETC_HOST_LOCALHOST_LINE="^.*127.0.0.1.*\$"
	if docker-machine ssh "${LOCAL_VM_NAME}" "grep '${DOCKER_CONTAINER}' /etc/hosts >/dev/null"; then
	eval $(docker-machine ssh "${LOCAL_VM_NAME}" "sudo sed -i 's/^.*${DOCKER_CONTAINER}.*\$/${IP} ${DOCKER_CONTAINER} ${LOCAL_VM_NAME}/' /etc/hosts")
	eval $(docker-machine ssh "${LOCAL_VM_NAME}" "sudo sed -i 's/${REGEX_ETC_HOST_LOCALHOST_LINE}/${ETC_HOST_LOCALHOST_LINE}/' /etc/hosts")
	else
	docker-machine ssh "${LOCAL_VM_NAME}" "sudo sh -c \"echo '${IP} ${DOCKER_CONTAINER} ${LOCAL_VM_NAME}' >> /etc/hosts\""
	docker-machine ssh "${LOCAL_VM_NAME}" "sudo sed -i 's/${REGEX_ETC_HOST_LOCALHOST_LINE}/${ETC_HOST_LOCALHOST_LINE}/' /etc/hosts"
	fi

	echo "Execute: docker-compose up -d"
}

set_hbase_hostname() {
	sed 's/^.* HOSTNAME.*/HOSTNAME='"$LOCAL_VM_NAME"'/' ./hbase/config-hbase-template.sh > ./hbase/config-hbase.sh
}

copy_build_resources() {
	FILE=spark-2.4.4-bin-without-hadoop.tgz
	cp ./resources/$FILE ./hadoop/$FILE
	FILE=hadoop-2.8.5.tar.gz
    cp ./resources/$FILE ./hadoop/$FILE
    FILE=hbase-1.4.10-bin.tar.gz
	cp ./resources/$FILE ./hbase/$FILE
}

allow_vm_machine_assessment() {
	echo
	echo
	echo "Register ssh connection to the docker-machine ${LOCAL_VM_NAME}"
	echo "Step1. Register in ssh-connection by Yes"
	echo "Step2. Insert 'tcuser', the default password of the docker-machine"
	echo "Step3. Insert 'exit' after succeeding to join the docker-machine"
	echo
	echo

 	ssh docker@"${LOCAL_VM_NAME}"
}

help_function() {
	echo ""
	echo "Usage: $0 -v docker_machine_name"
	exit 1
}


main() {
	while getopts "v:" opt
	do
	case "$opt" in
      v ) LOCAL_VM_NAME="$OPTARG" ;;
	  * ) help_function ;;
	esac
	done

	if [ -z "$LOCAL_VM_NAME" ] 
	then
		echo "Some variable is empty"
		help_function
	fi

	docker-machine create -d virtualbox --virtualbox-memory "4096" $LOCAL_VM_NAME
	IP=$(docker-machine ip ${LOCAL_VM_NAME})
	if [ -z "$IP" ] 
	then
		echo "Inject a static ip to docker-machine"
		config_vm_ip
	fi

	echo "docker-machine ip: ${IP}"

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

