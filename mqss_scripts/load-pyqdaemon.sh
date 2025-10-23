#!/usr/bin/bash

# logfile for load script
# LOGFILE="/home/ubuntu/shared_nfs_slurm/mqss-scripts/log_load_pyqdaemon.txt"

# load spack env and needed packages
. /home/ubuntu/spack/share/spack/setup-env.sh
spack env activate mqss
spack load rabbitmq-server@3.12.12
spack load py-hpcqc-qdaemon@0.3.5

# check the location of qdaemon
QD_LOCATION=$(spack location -i py-hpcqc-qdaemon)
# echo "Location qdaemon: $QD_LOCATION"                  > $LOGFILE

# echo "----------------------------------------------" >> $LOGFILE
# echo "                                              " >> $LOGFILE
# RUN_QDAEMON=$(py_qdaemon --config-file $QD_LOCATION/lib/python3.11/site-packages/hpcqc/config/qd-config.json &)
# RUN_QDAEMON=$({ py_qdaemon --config-file $QD_LOCATION/lib/python3.11/site-packages/hpcqc/config/qd-config.json & } > /dev/null 2>&1; QDPID=$!; disown "$QDPID")
# echo $QDPID > /tmp/qis-qdpid
py_qdaemon --config-file $QD_LOCATION/lib/python3.11/site-packages/hpcqc/config/qd-config.json
# nohup py_qdaemon --config-file $QD_LOCATION/lib/python3.11/site-packages/hpcqc/config/qd-config.json > /dev/null 2>&1 &
# echo $! > /tmp/slurm_jobs/pyqdaemon_$UID.pid
# printf "\n" | echo "Done"

# echo "$RUN_QDAEMON"                                   >> $LOGFILE
# echo "----------------------------------------------" >> $LOGFILE
# echo "                                              " >> $LOGFILE

