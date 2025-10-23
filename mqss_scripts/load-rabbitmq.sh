#!/usr/bin/bash

# token for erlang authentication
ERLANG_COOKIE="XXJCSDABPFFYLHVZGWKW"

# logfile for load script
# LOGFILE="/home/ubuntu/shared_nfs_slurm/mqss-scripts/log_load_rabbitmq.txt"

# load spack env and needed packages
. /home/ubuntu/spack/share/spack/setup-env.sh
spack env activate mqss
spack load rabbitmq-server@3.12.12
spack load py-hpcqc-qdaemon@0.3.5

export ELIXIR_ERL_OPTIONS="+fnu"

# check the location of rabbitmq
RMQ_LOCATION=$(spack location -i rabbitmq-server)
# echo "Location rabbitm: $RMQ_LOCATION" >> $LOGFILE

# check the pid file of rabbitmq
RABBITMQ_PID_FILE=$RMQ_LOCATION/var/lib/rabbitmq/mnesia/rabbit@$HOSTNAME.pid
cp -f $RMQ_LOCATION/var/lib/rabbitmq/.erlang.cookie ~/
# echo "Location rabbitmq-pid file: $RABBITMQ_PID_FILE" >> $LOGFILE
# echo "----------------------------------------------" >> $LOGFILE
# echo "                                              " >> $LOGFILE

# start rabbitmq-server in background
rabbitmq-server -detached
rabbitmqctl wait $RABBITMQ_PID_FILE --erlang-cookie $ERLANG_COOKIE
# echo "Started rabbitmq-server ..."                    >> $LOGFILE
# echo "----------------------------------------------" >> $LOGFILE
# echo "                                              " >> $LOGFILE