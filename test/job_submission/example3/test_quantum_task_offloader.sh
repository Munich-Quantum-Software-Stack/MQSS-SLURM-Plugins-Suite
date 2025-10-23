echo '--------------------------------------------------'
echo 'Check offloading quantum task over qdaemon ...'
echo '--------------------------------------------------'
echo ''
echo 'Load spack env: '
echo '  + load /home/ubuntu/spack/share/spack/setup-env.sh'
. /home/ubuntu/spack/share/spack/setup-env.sh
# spack env activate -d /home/ubuntu/qis-spack/env/wolpy
spack env activate mqss
echo '  + load rabbitmq-server@3.12.12'
echo '  + load py-hpcqc-qdaemon@0.3.5'
echo '  + load py-hpc-offload-provider'
echo '  + load py-qiskit'
spack load py-hpcqc-qdaemon@0.3.5
spack load rabbitmq-server@3.12.12
spack load py-hpc-offload-provider
spack load py-qiskit
echo 'Running rabbitmq-server and py_qdaemon in the background'
rabbitmq-server -detached
sleep 5
py_qdaemon --config-file /home/ubuntu/spack/opt/spack/linux-ubuntu22.04-icelake/gcc-11.4.0/py-hpcqc-qdaemon-0.3.5-th7lt5cjwaep4qyeeat62kuytqbpmznt/lib/python3.11/site-packages/hpcqc/config/qd-config.json &
sleep 2

echo 'Running quantum task'
python ./hpc-provider-ex.py
echo ''
echo 'Stopping rabbitmq and qdaemon'
pkill -f python3.11
pkill -f rabbitmq-server
echo 'Done ...'
