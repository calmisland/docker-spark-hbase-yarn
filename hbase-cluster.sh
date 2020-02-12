#!/bin/bash
DOCKER_MACHINE_DEFAULT_PASSWORD=tcuser
function create_table() {
	$ACCESS_DOCKER_MACHINE_SHELL "docker cp $(pwd)/hbase/hbase-schema-local.rb hbase-master:/opt/hbase/conf/hbase-schema.rb"
	$ACCESS_DOCKER_MACHINE_SHELL "docker exec hbase-master bash -c 'cat /opt/hbase/conf/hbase-schema.rb | /opt/hbase/bin/hbase shell'"
}

function start() {
	is_host_info_included=$($ACCESS_DOCKER_MACHINE_SHELL "cat /etc/hosts | grep -c \"192.168.99.50\"")
    if [ "$is_host_info_included" = "0" ]; then
        $ACCESS_DOCKER_MACHINE_SHELL "sudo sh -c \"echo '192.168.99.50  hbase-master "${LOCAL_VM_MACHINE}"' >> /etc/hosts\""
    fi
    $ACCESS_DOCKER_MACHINE_SHELL "cd '$(pwd)' && sudo cp ./resources/docker-compose-1.25.1-Linux-x86_64 /usr/local/bin/docker-compose"
    $ACCESS_DOCKER_MACHINE_SHELL "sudo chmod +x /usr/local/bin/docker-compose"
    $ACCESS_DOCKER_MACHINE_SHELL "cd '$(pwd)' && docker-compose up"
}

function start_after_reboot() {
	docker-machine start "${LOCAL_VM_MACHINE}"
	docker-machine regenerate-certs "${LOCAL_VM_MACHINE}"
	docker-machine env "${LOCAL_VM_MACHINE}"
	start
}

function stop() {
    $ACCESS_DOCKER_MACHINE_SHELL "cd '$(pwd)' && docker-compose stop"
}

function down() {
	$ACCESS_DOCKER_MACHINE_SHELL "cd '$(pwd)' && docker-compose down"
}

function logs() {
    $ACCESS_DOCKER_MACHINE_SHELL "cd '$(pwd)' && docker-compose logs -ft"
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

	ACCESS_DOCKER_MACHINE_SHELL="sshpass -p "${DOCKER_MACHINE_DEFAULT_PASSWORD}" ssh docker@"${LOCAL_VM_MACHINE}""

    case "$PURPOSE" in
		create_table) create_table	;;
		down)      down     ;;
		start)     start    ;;
		start_after_reboot)  start_after_reboot ;;
		stop)      stop     ;;
		logs)      logs   ;;
		*)         usage    ;;
	esac
}

main "$@"
