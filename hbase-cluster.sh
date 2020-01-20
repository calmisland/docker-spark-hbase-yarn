#!/bin/bash
DOCKER_MACHINE_DEFAULT_PASSWORD=tcuser
function start() {
    is_host_info_included=$(sshpass -p "${DOCKER_MACHINE_DEFAULT_PASSWORD}" ssh docker@"${LOCAL_VM_MACHINE}" "cat /etc/hosts | grep -c \"192.168.99.50\"")
    if [ "$is_host_info_included" = "0" ]; then
        sshpass -p "${DOCKER_MACHINE_DEFAULT_PASSWORD}" ssh docker@"${LOCAL_VM_MACHINE}" "sudo sh -c \"echo '192.168.99.50  hbase-master datapipeline' >> /etc/hosts\""
    fi

    sshpass -p "${DOCKER_MACHINE_DEFAULT_PASSWORD}" ssh docker@"${LOCAL_VM_MACHINE}" "cd '$(pwd)' && sudo cp ./resources/docker-compose-1.25.1-Linux-x86_64 /usr/local/bin/docker-compose"
    sshpass -p "${DOCKER_MACHINE_DEFAULT_PASSWORD}" ssh docker@"${LOCAL_VM_MACHINE}" "sudo chmod +x /usr/local/bin/docker-compose"
    sshpass -p "${DOCKER_MACHINE_DEFAULT_PASSWORD}" ssh docker@"${LOCAL_VM_MACHINE}" "cd '$(pwd)' && docker-compose up"
}

function stop() {
    sshpass -p "${DOCKER_MACHINE_DEFAULT_PASSWORD}" ssh docker@"${LOCAL_VM_MACHINE}" "cd '$(pwd)' && docker-compose stop"
}

function logs() {
    sshpass -p "${DOCKER_MACHINE_DEFAULT_PASSWORD}" ssh docker@"${LOCAL_VM_MACHINE}" "cd '$(pwd)' && docker-compose logs -ft"
}

function usage() {
	echo "Usage: $0 -p [start|stop|logs] -v docker_machine_name"
	exit 1
}

function main() {
    [ -z "$*" ] && usage

    while getopts "p:v:" opt
	do
	case "$opt" in
      p ) PURPOSE="$OPTARG" ;;
      v ) LOCAL_VM_MACHINE="$OPTARG" ;;
	  * ) usage ;;
	esac
	done

    case "$PURPOSE" in
		start)     start    ;;
		stop)      stop     ;;
		logs)      logs   ;;
		*)         usage    ;;
	esac
}

main "$@"