#!/bin/bash
set -euxo pipefail

source static-info.sh
ACCESS_DOCKER_MACHINE_SHELL="sshpass -p "${DOCKER_MACHINE_DEFAULT_PASSWORD}" ssh docker@"${DOCKER_MACHINE_NAME}""

function create_table() {
	$ACCESS_DOCKER_MACHINE_SHELL "docker cp $(pwd)/hbase/hbase-schema-local.rb hbase-master:/opt/hbase/conf/hbase-schema.rb"
	$ACCESS_DOCKER_MACHINE_SHELL "docker exec ${HBASE_CONTAINER} bash -c 'cat /opt/hbase/conf/hbase-schema.rb | /opt/hbase/bin/hbase shell'"
}

function start() {
	start_docker_machine
	configure_ip
	start_cluster
}

function start_docker_machine() {
	status=$(docker-machine status "${DOCKER_MACHINE_NAME}")
	if [ "${status}" = "Stopped" ]; then
		docker-machine start "${DOCKER_MACHINE_NAME}"
		ip=$(docker-machine ip ${DOCKER_MACHINE_NAME})
		docker-machine regenerate-certs -f "${DOCKER_MACHINE_NAME}"
		docker-machine env "${DOCKER_MACHINE_NAME}"
	fi
}

function configure_ip() {
	ip=$(docker-machine ip ${DOCKER_MACHINE_NAME})

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
function start_cluster() {
	$ACCESS_DOCKER_MACHINE_SHELL "cd '$(pwd)' && sudo cp ./resources/docker-compose-1.25.1-Linux-x86_64 /usr/local/bin/docker-compose"
    $ACCESS_DOCKER_MACHINE_SHELL "sudo chmod +x /usr/local/bin/docker-compose"
    $ACCESS_DOCKER_MACHINE_SHELL "cd '$(pwd)' && docker-compose up"
}


function stop() {
    $ACCESS_DOCKER_MACHINE_SHELL "cd '$(pwd)' && docker-compose stop"
}

function destroy() {
	$ACCESS_DOCKER_MACHINE_SHELL "cd '$(pwd)' && docker-compose down"
}

function restart() {
	docker-machine stop  "${DOCKER_MACHINE_NAME}"
	start
}

function logs() {
    $ACCESS_DOCKER_MACHINE_SHELL "cd '$(pwd)' && docker-compose logs -ft"
}

function usage() {
	echo "Usage: $0 -p [create_table|down|start|stop|logs]"
	exit 1
}

function main() {
    [ -z "$*" ] && usage

    while getopts "p:" opt
	do
	case "$opt" in
      p ) PURPOSE="$OPTARG" ;;
	  * ) usage ;;
	esac
	done

    case "$PURPOSE" in
		create_table) create_table	;;
		destroy)      destroy     ;;
		start)     start    ;;
		stop)      stop     ;;
		restart)	restart	;;
		logs)      logs   ;;
		*)         usage    ;;
	esac
}

main "$@"
