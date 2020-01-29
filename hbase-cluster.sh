#!/bin/bash
DOCKER_MACHINE_DEFAULT_PASSWORD=tcuser
function start() {
    is_host_info_included=$(sshpass -p "${DOCKER_MACHINE_DEFAULT_PASSWORD}" ssh docker@"${LOCAL_VM_MACHINE}" "cat /etc/hosts | grep -c \"192.168.99.50\"")
    if [ "$is_host_info_included" = "0" ]; then
        sshpass -p "${DOCKER_MACHINE_DEFAULT_PASSWORD}" ssh docker@"${LOCAL_VM_MACHINE}" "sudo sh -c \"echo '192.168.99.50  hbase-master "${LOCAL_VM_MACHINE}"' >> /etc/hosts\""
    fi
    sshpass -p "${DOCKER_MACHINE_DEFAULT_PASSWORD}" ssh docker@"${LOCAL_VM_MACHINE}" "cd '$(pwd)' && sudo cp ./resources/docker-compose-1.25.1-Linux-x86_64 /usr/local/bin/docker-compose"
    sshpass -p "${DOCKER_MACHINE_DEFAULT_PASSWORD}" ssh docker@"${LOCAL_VM_MACHINE}" "sudo chmod +x /usr/local/bin/docker-compose"
    sshpass -p "${DOCKER_MACHINE_DEFAULT_PASSWORD}" ssh docker@"${LOCAL_VM_MACHINE}" "cd '$(pwd)' && docker-compose up"
	echo "Hello"
}

function start_after_reboot() {
	docker-machine start "${LOCAL_VM_MACHINE}"
	docker-machine regenerate-certs "${LOCAL_VM_MACHINE}"
	docker-machine env "${LOCAL_VM_MACHINE}"
	start
}

function stop() {
    sshpass -p "${DOCKER_MACHINE_DEFAULT_PASSWORD}" ssh docker@"${LOCAL_VM_MACHINE}" "cd '$(pwd)' && docker-compose stop"
}

function down() {
	sshpass -p "${DOCKER_MACHINE_DEFAULT_PASSWORD}" ssh docker@"${LOCAL_VM_MACHINE}" "cd '$(pwd)' && docker-compose down"
}

function logs() {
    sshpass -p "${DOCKER_MACHINE_DEFAULT_PASSWORD}" ssh docker@"${LOCAL_VM_MACHINE}" "cd '$(pwd)' && docker-compose logs -ft"
}

function usage() {
	echo "Usage: $0 -p [down|start|start_after_reboot|stop|logs] -v docker_machine_name"
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
		down)      down     ;;
		start)     start    ;;
		start_after_reboot)  start_after_reboot ;;
		stop)      stop     ;;
		logs)      logs   ;;
		*)         usage    ;;
	esac
}

main "$@"
