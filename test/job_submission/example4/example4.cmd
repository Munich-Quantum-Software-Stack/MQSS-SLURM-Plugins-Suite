#!/bin/sh
#SBATCH -J example4
#SBATCH -o ./%x_%j.out
#SBATCH -e ./%x_%j.err
#SBATCH --ntasks=1
#SBATCH --gres=qpu:1
#SBATCH --cpus-per-task=1
#SBATCH --partition=testbed
#SBATCH --time=00:00:45

echo 'Submitted a sample job with qpu requirement ...'
echo 'Checking the hostname, where the job is allocated and run: '
hostname

echo ''
echo '---------------------------------'
echo 'Loading the spack env'
. /home/ubuntu/spack/share/spack/setup-env.sh
spack env activate mqss
spack load py-hpc-offload-provider 
spack load py-qiskit
# spack load rabbitmq-server@3.12.12
# spack load py-hpcqc-qdaemon@0.3.5
echo ''

echo '--------------------------------------'
echo 'Starting rabbitmq-server and py_qdaemon'
source /home/ubuntu/shared_nfs_slurm/mqss-scripts/load-mqss.sh
echo '--------------------------------------'
echo ''

# ERLANG_COOKIE="XXJCSDABPFFYLHVZGWKW"
# QD_LOCATION=$(spack location -i py-hpcqc-qdaemon)
# RMQ_LOCATION=$(spack location -i rabbitmq-server)
# RABBITMQ_PID_FILE=${RMQ_LOCATION}/var/lib/rabbitmq/mnesia/rabbit@$HOSTNAME.pid
# cp -f ${RMQ_LOCATION}/var/lib/rabbitmq/.erlang.cookie ~/
# rabbitmq-server -detached

# Wait until the rabbitmq-server starts already
# rabbitmqctl wait ${RABBITMQ_PID_FILE} --erlang-cookie ${ERLANG_COOKIE}

# { py_qdaemon --config-file ${QD_LOCATION}/lib/python3.11/site-packages/hpcqc/config/qd-config.json & } 
# > /dev/null 2>&1; QDPID=$!; disown "$QDPID"
# echo $QDPID > /tmp/qis-qdpid

# RABBITMQ_RUN=$(rabbitmq-server &)
# echo '${RABBITMQ_RUN}'
# sleep 7
# RABBITMQ_STAT=$(rabbitmqctl status)
# echo '${RABBITMQ_STAT}'
# echo '--------------------------------------'

# run the quantum task
echo '--------------------------------------'
echo 'Run the quantum application'
python3.11 ./hpc-provider-ex.py
echo '--------------------------------------'
echo ''

# echo 'Stopping rabbitmq-server and py_qdaemon'
# pkill -f python3.11
# rabbitmqctl shutdown --erlang-cookie ${ERLANG_COOKIE}
# spack unload py-hpcqc-qdaemon@0.3.5
# spack unload rabbitmq-server@3.12.12
# source /home/ubuntu/shared_nfs_slurm/mqss-scripts/unload-mqss.sh
# echo '--------------------------------------'
# echo ''

