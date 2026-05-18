#!/usr/bin/bash
echo "----------------------------------------"
echo "Check py_qdaemon running ..."
echo "----------------------------------------"
ps -aux | grep qdaemon

echo ""
echo "----------------------------------------"
echo "Check rabbitmq-server running ..."
echo "----------------------------------------"
ps -aux | grep rabbit

