#!/usr/bin/bash
#exec > /dev/null 2>&1

# token for erlang authentication
ERLANG_COOKIE="XXJCSDABPFFYLHVZGWKW"

# logfile for load script
# LOGFILE="/home/ubuntu/shared_nfs_slurm/mqss-scripts/log_load_mqss.txt"

# load spack env and needed packages
. /home/ubuntu/spack/share/spack/setup-env.sh
spack env activate mqss
spack load rabbitmq-server@3.12.12
spack load py-hpcqc-qdaemon@0.3.5

export ELIXIR_ERL_OPTIONS="+fnu"

# check the location of rabbitmq and qdaemon
QD_LOCATION=$(spack location -i py-hpcqc-qdaemon)
RMQ_LOCATION=$(spack location -i rabbitmq-server)
# echo "Location qdaemon: $QD_LOCATION"   > $LOGFILE
# echo "Location rabbitm: $RMQ_LOCATION" >> $LOGFILE

RABBITMQ_PID_FILE=$RMQ_LOCATION/var/lib/rabbitmq/mnesia/rabbit@$HOSTNAME.pid
cp -f $RMQ_LOCATION/var/lib/rabbitmq/.erlang.cookie ~/
# echo "Location rabbitmq-pid file: $RABBITMQ_PID_FILE" >> $LOGFILE
# echo "----------------------------------------------" >> $LOGFILE
# echo "                                              " >> $LOGFILE

rabbitmq-server -detached
rabbitmqctl wait $RABBITMQ_PID_FILE --erlang-cookie $ERLANG_COOKIE
# echo "Started rabbitmq-server ..."                  >> $LOGFILE

# nohup py_qdaemon --config-file $QD_LOCATION/lib/python3.11/site-packages/hpcqc/config/qd-config.json &
# { py_qdaemon --config-file $QD_LOCATION/lib/python3.11/site-packages/hpcqc/config/qd-config.json & } > /dev/null 2>&1; QDPID=$!; disown "$QDPID"
# RUN_QDAEMON=$(py_qdaemon --config-file $QD_LOCATION/lib/python3.11/site-packages/hpcqc/config/qd-config.json &)
# RUN_QDAEMON=$({ py_qdaemon --config-file $QD_LOCATION/lib/python3.11/site-packages/hpcqc/config/qd-config.json & } > /dev/null 2>&1; QDPID=$!; disown "$QDPID")
# systemctl start py-qdaemon.service

# echo "Started py_qdaemon ..."                         >> $LOGFILE
# echo "$RUN_QDAEMON"                                   >> $LOGFILE 
# echo "----------------------------------------------" >> $LOGFILE
# echo "                                              " >> $LOGFILE

