echo 'Running rabbitmq-server and py_qdaemon in the background'
rabbitmq-server &
sleep 5
py_qdaemon --config-file /home/ubuntu/spack/opt/spack/linux-ubuntu22.04-icelake/gcc-11.4.0/py-hpcqc-qdaemon-0.3.5-th7lt5cjwaep4qyeeat62kuytqbpmznt/lib/python3.11/site-packages/hpcqc/config/qd-config.json &
sleep 2

