#!/usr/bin/bash
#
# An Epilog script at job termination, which check the running qdaemon and rabbitmq-server
# then finalize these services because the job does not need anymore
#

# Create tmp folder and log file
mkdir -p /tmp/slurm_jobs

# Direct job information to the logfile
echo "----------------------------------------"  > /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
echo "SLURM EPILOG SCRIPT: TERMI              " >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
echo "Epilog info of the job: ID=$SLURM_JOB_ID" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
echo "----------------------------------------" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log

# Check QPU jobs
VAR_GRES=$(scontrol show job $SLURM_JOB_ID | grep "qpu:")

if [[ "$VAR_GRES" == *qpu* ]]
then
  echo "Detected the terminated job with QPU requirement" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
  echo "  + Loading spack environment" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
  . /home/ubuntu/spack/share/spack/setup-env.sh
  spack env activate mqss
  
  echo "DEBUG: switch to the user account - $SLURM_JOB_ACCOUNT" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
  SWITCH_USER=$(su ubuntu)
  echo "DEBUG: check switch user - ${SWITCH_USER}" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
  USER_ACCOUNT=$(whoami)
  echo "DEBUG: check USER_ACCOUNT - ${USER_ACCOUNT}" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
  # ERLANG_COOKIE="XXJCSDABPFFYLHVZGWKW"

  echo "  + Stop the py_qdaemon process" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
  pkill -f python3.11

  # echo "  + Stop the rabbitmq-server process" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
  # rabbitmqctl shutdown --erlang-cookie ${ERLANG_COOKIE}

  # echo "  + Stop the rabbitmq-server docker"    >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
  # docker-compose -f /home/ubuntu/shared_nfs_slurm/qdaemon/docker_rabbitmq_server/docker-compose.yaml down

  # echo "  + Unload the spack packages" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
  # spack unload py-hpcqc-qdaemon@0.3.5
  # spack unload rabbitmq-server@3.12.12

else
  echo "Job without QPU requirement | Do nothing" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
fi

# End epilog script
echo "----------------------------------------" >> /tmp/slurm_jobs/epi_j$SLURM_JOB_ID.log
