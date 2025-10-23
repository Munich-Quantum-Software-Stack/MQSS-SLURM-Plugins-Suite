. /home/ubuntu/spack/share/spack/setup-env.sh
spack env activate mqss
spack load py-hpcqc-qdaemon@0.3.5
spack load rabbitmq-server@3.12.12
spack load py-hpc-offload-provider
spack load py-qiskit

rabbitmq-server &
