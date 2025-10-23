#!/usr/bin/bash
#exec > /dev/null 2>&1

export ELIXIR_ERL_OPTIONS="+fnu"
export ERL_AFLAGS="+fnu"
ERLANG_COOKIE="DWQEZFOIBCZTUKKYEVPF"

# because of using root anyway, so set directly USER=root
USERNAME=$(whoami)
mkdir -p /tmp/$USERNAME/$HOSTNAME/mnesia
export RABBITMQ_MNESIA_DIR=/tmp/$USERNAME/$HOSTNAME/mnesia

source /etc/profile.d/modules.sh 
module use -p /home/sw/qis/wolpy/mqss/modules/linux-rocky9-icelake/
module load rabbitmq-server

RMQ_LOCATION=$(which rabbitmq-server)
RMQ_LOCATION=${RMQ_LOCATION%/bin/rabbitmq-server}
RABBITMQ_PID_FILE=${RMQ_LOCATION}/var/lib/rabbitmq/mnesia/rabbit@$HOSTNAME.pid
cp -f ${RMQ_LOCATION}/var/lib/rabbitmq/.erlang.cookie ~/
chmod 600 ~/.erlang.cookie

rabbitmq-server -detached
rabbitmqctl wait ${RABBITMQ_PID_FILE} --erlang-cookie ${ERLANG_COOKIE}

# exec $SHELL
