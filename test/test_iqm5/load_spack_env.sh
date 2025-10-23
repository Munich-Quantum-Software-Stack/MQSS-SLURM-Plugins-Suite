echo '--------------------------------------------------'
echo 'Check offloading quantum task over qdaemon ...'
echo '--------------------------------------------------'
echo ''
echo 'Load spack env: '
echo '  + load /home/ubuntu/spack/share/spack/setup-env.sh'
. /home/ubuntu/spack/share/spack/setup-env.sh
spack env activate -d /home/ubuntu/qis-spack/env/wolpy
echo '  + load rabbitmq-server@3.12.12'
echo '  + load py-hpcqc-qdaemon@0.3.5'
echo '  + load py-hpc-offload-provider'
echo '  + load py-qiskit'
spack load py-hpcqc-qdaemon@0.3.5
spack load rabbitmq-server@3.12.12
spack load py-hpc-offload-provider
spack load py-qiskit
