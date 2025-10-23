#!/usr/bin/bash
#
# A taskprolog script prior to launching job steps, which will check the job with QPU requirement
# and init the needed quantum daemons for offloading quantum tasks to quantum machines
# 

# For creating log file along with the prolog script
# mkdir -p /tmp/slurm_jobs
LOG_FILE=/tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log

# Direct job information to the logfile
printf "----------------------------------------"  > $LOG_FILE
printf "SLURM TASKPROLOG SCRIPT: PRIOR LAUNCHING JOB STEPS" >> $LOG_FILE
printf "Log info of the job: ID=%s" $SLURM_JOB_ID >> $LOG_FILE
printf "----------------------------------------" >> $LOG_FILE

# Check QPU jobs
VAR_GRES=$(scontrol show job $SLURM_JOB_ID | grep "qpu:")

if [[ "$VAR_GRES" == *qpu* ]]
then
  printf "Detected job with QPU requirement: %s" $VAR_GRES >> $LOG_FILE
  echo "  + Load the env of spack: . ~/spack/share/spack/setup-env.sh" >> $LOG_FILE
  . /home/ubuntu/spack/share/spack/setup-env.sh

  echo "  + Spack activate env" >> $LOG_FILE
  # spack env activate -d /home/ubuntu/qis-spack/env/wolpy
  spack env activate mqss

  echo "  + Spack load rabbitmq-server and qy_qdaemon" >> $LOG_FILE
  spack load rabbitmq-server@3.12.12
  spack load py-hpcqc-qdaemon@0.3.5

  echo "  + Start rabbitmq-server in the background" >> $LOG_FILE
  echo "    ---------------------------------------" >> $LOG_FILE
  DATELOG=$(date -u)
  echo "    DEBUG: before starting  - ${DATELOG}" >> $LOG_FILE
  ACCOUNT=$(whoami)
  echo "    DEBUG: working account  - ${ACCOUNT}" >> $LOG_FILE
  HOSTLOC=$(hostname)
  RABBITMQ_PID_FILE=${RMQ_LOCATION}/var/lib/rabbitmq/mnesia/rabbit@$HOSTLOC.pid
  echo "    DEBUG: host running prolog - ${HOSTLOC}" >> $LOG_FILE

  ERLANG_COOKIE="XXJCSDABPFFYLHVZGWKW"
  RMQ_LOCATION=$(spack location -i rabbitmq-server)
  echo "$RMQ_LOCATION" >> $LOG_FILE

  RABBITMQ_PID_FILE=${RMQ_LOCATION}/var/lib/rabbitmq/mnesia/rabbit@$HOSTLOC.pid
  echo "$RABBITMQ_PID_FILE" >> $LOG_FILE

  cp -f ${RMQ_LOCATION}/var/lib/rabbitmq/.erlang.cookie ~/
  RABBITMQ_BG=$(rabbitmq-server)
  # RABBITMQ_BG=$(rabbitmq-server -detached)
  echo "    DEBUG: start rabbitmq-server" >> $LOG_FILE
  echo "${RABBITMQ_BG}" >> $LOG_FILE 2>&1
  sleep 10

  echo "    DEBUG: check rabbit@slurmnode1.pid file" >> $LOG_FILE
  LSPIDFILE=$(ls ${RMQ_LOCATION}/var/lib/rabbitmq/mnesia)
  echo "${LSPIDFILE}" >> $LOG_FILE 2>&1

  RABBITMQ_WA=$(rabbitmqctl wait ${RABBITMQ_PID_FILE} --erlang-cookie ${ERLANG_COOKIE})
  # RABBITMQ_WA=$(rabbitmqctl wait ${RABBITMQ_PID_FILE})
  echo "    DEBUG: wait until rabbitmq-server started" >> $LOG_FILE
  echo "${RABBITMQ_WA}" >> $LOG_FILE 2>&1

  RABBITMQ_STAT=$(rabbitmq-diagnostics status)
  echo "    DEBUG: check rabbitmq status" >> $LOG_FILE
  echo "${RABBITMQ_STAT}" >> $LOG_FILE 2>&1

  # echo "DEBUG: start rabbitmq by docker-compose" >> $LOG_FILE
  # docker-compose -f /home/ubuntu/shared_nfs_slurm/qdaemon/docker_rabbitmq_server/docker-compose.yaml up -d
  # sleep 5

  DATELOG=$(date -u)
  echo "    DEBUG: after starting - ${DATELOG}" >> $LOG_FILE
  echo "    ---------------------------------------" >> $LOG_FILE

  echo "  + Start py_qdaemon in the background" >> $LOG_FILE
  echo "    ---------------------------------------" >> $LOG_FILE
  DATELOG=$(date -u)
  echo "    DEBUG: before starting - ${DATELOG}" >> $LOG_FILE

  # QDAEMON_BG=$(py_qdaemon --config-file /home/ubuntu/spack/opt/spack/linux-ubuntu22.04-icelake/gcc-11.4.0/py-hpcqc-qdaemon-0.3.5-th7lt5cjwaep4qyeeat62kuytqbpmznt/lib/python3.11/site-packages/hpcqc/config/qd-config.json &)
  # echo "${QDAEMON_BG}" &>> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log

  QD_LOCATION=$(spack location -i py-hpcqc-qdaemon)
  echo "    DEBUG: py_qdaemon location $QD_LOCATION" >> $LOG_FILE

  # QD_RUNCOMMA=$({ py_qdaemon --config-file ${QD_LOCATION}/lib/python3.11/site-packages/hpcqc/config/qd-config.json & } > /dev/null 2>&1; QDPID=$!; disown "$QDPID")
  QD_RUNCOMMA=$(py_qdaemon --config-file ${QD_LOCATION}/lib/python3.11/site-packages/hpcqc/config/qd-config.json &)
  echo "    DEBUG: $QD_RUNCOMMA" >> $LOG_FILE 2>&1
  # echo $QDPID > /tmp/qis-qdpid
  # py_qdaemon --config-file ${QD_LOCATION}/lib/python3.11/site-packages/hpcqc/config/qd-config.json &
  sleep 2

  DATELOG=$(date -u)
  echo "    DEBUG: after starting - ${DATELOG}" >> $LOG_FILE
  echo "    ---------------------------------------" >> $LOG_FILE

  echo "  + Starting launch the quantum task ..." >> $LOG_FILE

else
  echo "Job without QPU requirement | Check: $VAR_GRES" >> $LOG_FILE
fi

# end logfile
echo "-------------------------------------------------" >> $LOG_FILE

