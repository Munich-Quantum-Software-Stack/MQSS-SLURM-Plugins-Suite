#!/usr/bin/bash

. /home/ubuntu/spack/share/spack/setup-env.sh
spack env activate mqss
spack load rabbitmq-server@3.12.12

ERLANG_COOKIE="XXJCSDABPFFYLHVZGWKW"

rabbitmqctl shutdown --erlang-cookie ${ERLANG_COOKIE}

spack unload rabbitmq-server@3.12.12

# CHECK_BASHQD_PID=$(ps -ef | grep [l]oad-pyqdaemon | awk '{print $2}')
# echo "Running bash process for loading qdaemon: $CHECK_BASHQD_PID"
# echo "Kill the bash running qdaemon process: "
# kill -9 $CHECK_BASHQD_PID
# echo "Double check the bash_qdaemon pid: "
# ps -ef | grep [l]oad-pyqdaemon
# echo " "
