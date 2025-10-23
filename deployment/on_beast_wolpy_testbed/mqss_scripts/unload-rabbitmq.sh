#!/usr/bin/bash
#exec > /dev/null 2>&1

export ELIXIR_ERL_OPTIONS="+fnu"
export ERL_AFLAGS="+fnu"
ERLANG_COOKIE="DWQEZFOIBCZTUKKYEVPF"

source /etc/profile.d/modules.sh 
module use -p /home/sw/qis/wolpy/mqss/modules/linux-rocky9-icelake/
module load rabbitmq-server

rabbitmqctl shutdown --erlang-cookie ${ERLANG_COOKIE}

rm -f ~/.erlang.cookie

RMQ_LOCATION=$(which rabbitmq-server)
RMQ_LOCATION=${RMQ_LOCATION%/bin/rabbitmq-server}

# because of using root anyway, so set directly USER=root
USERNAME=$(whoami)
find ${RMQ_LOCATION}/var/lib/rabbitmq/mnesia/* -user $USERNAME -exec chmod 777 {} ';'
find ${RMQ_LOCATION}/var/log/rabbitmq/* -user $USERNAME -exec chmod 777 {} ';'
find ${RMQ_LOCATION}/var/lib/rabbitmq/mnesia/* -user $USERNAME -delete
find /tmp/$USERNAME/$HOSTNAME/mnesia/* -user $USERNAME -delete

# screen -XS srabbit quit
