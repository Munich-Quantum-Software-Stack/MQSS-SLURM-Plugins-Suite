#!/usr/bin/bash
#exec > /dev/null 2>&1

. /home/ubuntu/spack/share/spack/setup-env.sh

spack env activate mqss

ERLANG_COOKIE="XXJCSDABPFFYLHVZGWKW"

CHECK_QD_SCREEN_PID=$(ps -ef | grep [s]creen_qdaemon | awk '{print $2}')
kill -9 $CHECK_QD_SCREEN_PID

rabbitmqctl shutdown --erlang-cookie ${ERLANG_COOKIE}

# spack unload py-hpcqc-qdaemon@0.3.5
# spack unload rabbitmq-server@3.12.12

