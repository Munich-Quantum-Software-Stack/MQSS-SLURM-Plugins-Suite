#!/usr/bin/bash
#
# An Epilog script at job termination, which check the running qdaemon and rabbitmq-server
# then finalize these services because the job does not need anymore
#

# Create tmp folder and log file
mkdir -p /tmp/slurm_jobs

# Direct job information to the logfile
echo "----------------------------------------" >  /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
echo "SLURM EPILOG SCRIPT: TERMI              " >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
echo "Epilog info of the job: ID=$SLURM_JOB_ID" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
echo "User submitted the job: $SLURM_JOB_USER " >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
echo "----------------------------------------" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log

# Time the job is completes
# -----------------------------------------------------
DATELOG=$(date -u)
echo "User application finished at time $DATELOG" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
# -----------------------------------------------------

# Check QPU jobs
VAR_GRES=$(scontrol show job $SLURM_JOB_ID | grep "qpu:")

if [[ "$VAR_GRES" == *qpu* ]]
then
  echo "Detected the terminated job with QPU requirement" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
  CHECK_QD_SCREEN_PID=$(ps -ef | grep [s]creen_pydaemon | awk '{print $2}')
  CHECK_QD_SCREEN_ACC=$(ps -ef | grep [s]creen_pydaemon | awk '{print $1}')
  # CHECK_PARTITION=$(/usr/local/bin/scontrol show node $HOSTNAME | grep Partitions)
  # PARTITION_NAME=$(sed -e "s#.*=\(\)#\1#" <<< $CHECK_PARTITION)
  # CHECK_QUEUED_JOBS=$(/usr/local/bin/squeue --partition=$PARTITION_NAME --states=PD | grep $PARTITION_NAME)
  # QUEUE_STATUS=$(echo $CHECK_QUEUED_JOBS | awk -F'[^0-9]+' '{ print $1 }')

  # echo "  + Partition: hostname=$HOSTNAME, partition=$PARTITION_NAME" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
  # echo "  + Queue status: $CHECK_QUEUED_JOBS" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
  # echo "  + Preprocess the status: $QUEUE_STATUS" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
  # echo " " >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log

  # -----------------------------------------------------
  DATELOG=$(date -u)
  echo "Start_time: unload rabbitmq and qdaemon - $DATELOG" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
  # echo " " >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
  # -----------------------------------------------------

  if [[ "$CHECK_QD_SCREEN_PID" != "" ]]
  then
    echo "Shutdown rabbitmq and qdaemon" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
    runuser -u $CHECK_QD_SCREEN_ACC -- /usr/bin/bash /home/ubuntu/shared_nfs_slurm/mqss-scripts/unload-pyqdaemon.sh
    runuser -u $CHECK_QD_SCREEN_ACC -- /usr/bin/bash /home/ubuntu/shared_nfs_slurm/mqss-scripts/unload-rabbitmq.sh
  fi

  # if [[ "$CHECK_QD_SCREEN_PID" != "" ] && [ "$QUEUE_STATUS" == "" ]]
  # then
  #   echo "DEBUG: no more jobs in the queue, shutdown rabbitmq and qdaemon" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
  #   runuser -u $CHECK_QD_SCREEN_ACC -- /usr/bin/bash /home/ubuntu/shared_nfs_slurm/mqss-scripts/unload-pyqdaemon.sh
  #   runuser -u $CHECK_QD_SCREEN_ACC -- /usr/bin/bash /home/ubuntu/shared_nfs_slurm/mqss-scripts/unload-rabbitmq.sh
  # else
  #   echo "DEBUG: other jobs are still running, keep rabbitmq and qdaemon running" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
  # fi

  # echo " " >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log

  # -----------------------------------------------------
  DATELOG=$(date -u)
  echo "End_time: unload rabbitmq and qdaemon - $DATELOG" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
  # -----------------------------------------------------

else
  echo "Job without QPU requirement | Do nothing" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
fi

# End epilog script
echo "----------------------------------------" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
