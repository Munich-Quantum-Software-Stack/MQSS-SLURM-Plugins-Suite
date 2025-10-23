#!/usr/bin/bash

CHECK_QD_SCREEN_PID=$(ps -ef | grep [s]creen_pydaemon_$USER | awk '{print $2}')
# echo "Running py_qdaemon process: $CHECK_QD_PID"
# echo "Kill the qdaemon process: "
kill -9 $CHECK_QD_SCREEN_PID
# echo "Double check the qdaemon pid: "
# ps -ef | grep [p]yqdaemon
# echo " "
