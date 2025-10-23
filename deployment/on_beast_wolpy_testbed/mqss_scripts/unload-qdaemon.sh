#!/usr/bin/bash
#exec > /dev/null 2>&1

USERNAME=$(whoami)
QDPID=$(</tmp/$USERNAME/$HOSTNAME/qis-qdpid)
kill -9 $QDPID

screen -XS sqdaemon quit
