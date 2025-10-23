#!/usr/bin/bash
#
# A Prolog script at job allocation, which will check the job with QPU requirement
# and init the needed quantum daemons to do offloading quantum tasks to quantum machines
#

# For creating log file along with the prolog script
mkdir -p /tmp/slurm_jobs

# Direct job information to the logfile
echo "----------------------------------------" >  /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log
echo "SLURM PROLOG SCRIPT: ALLOC              " >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log
echo "Log info of the job: ID=$SLURM_JOB_ID   " >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log
echo "User submitted the job: $SLURM_JOB_USER " >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log
echo "----------------------------------------" >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log

# Check QPU jobs
VAR_GRES=$(scontrol show job $SLURM_JOB_ID | grep "qpu:")

if [[ "$VAR_GRES" == *qpu* ]]
then
  echo "Detected job with QPU requirement: $VAR_GRES" >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log
  # CHECK_QD_SCREEN_PID=$(ps -ef | grep [s]creen_pydaemon | awk '{print $2}')

  # -----------------------------------------------------
  DATELOG=$(date -u)
  echo "Start_time: load rabbitmq and qdaemon - $DATELOG" >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log
  # -----------------------------------------------------

  # runuser -u $SLURM_JOB_USER -- /usr/bin/bash /home/ubuntu/shared_nfs_slurm/mqss-scripts/load-rabbitmq.sh
  # runuser -u $SLURM_JOB_USER -- screen -S screen_pydaemon -d -m /usr/bin/bash /home/ubuntu/shared_nfs_slurm/mqss-scripts/load-pyqdaemon.sh
  sleep 1

  # if [[ "$CHECK_QD_SCREEN_PID" == "" ]]
  # then
  #   echo "[DEBUG] rabbitmq-server and qdaemon are not running yet. Run!" >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log
  #   runuser -u $SLURM_JOB_USER -- /usr/bin/bash /home/ubuntu/shared_nfs_slurm/mqss-scripts/load-rabbitmq.sh
  #   runuser -u $SLURM_JOB_USER -- screen -S screen_pydaemon -d -m /usr/bin/bash /home/ubuntu/shared_nfs_slurm/mqss-scripts/load-pyqdaemon.sh
  # else
  #   echo "[DEBUG] rabbitmq-server and qdaemon are already started. Skip!" >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log
  # fi
  # sleep 1

  # -----------------------------------------------------
  DATELOG=$(date -u)
  echo "End_time: load rabbitmq and qdaemon - $DATELOG" >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log
  # -----------------------------------------------------

  # check rabbitmq status
  # RABBITMQ_STATUS=$(rabbitmq-diagnostics status)
  # echo "DEBUG: rabbitmq-server ${RABBITMQ_STATUS}" >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log

  # ACCOUNT=$(whoami)
  # echo "Running account: ${ACCOUNT}" >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log

  # time to run the user application
  # -----------------------------------------------------
  DATELOG=$(date -u)
  echo "Run user application at time $DATELOG" >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log
  # -----------------------------------------------------
  
else
  echo "Job without QPU requirement | Check: $VAR_GRES" >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log
fi

# End logfile
echo "----------------------------------------" >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log

