#!/usr/bin/bash
#exec > /dev/null 2>&1

source /etc/profile.d/modules.sh
module use -p /home/sw/qis/wolpy/mqss/modules/linux-rocky9-icelake/
module load py-hpcqc-qdaemon

QD_LOCATION=$(which py_qdaemon)
QD_LOCATION=${QD_LOCATION%/bin/py_qdaemon}
export QD_LOGGING=TRUE

{ py_qdaemon --config-file /home/sw/qis/wolpy/mqss/configs/qd/qd-config.json & } > /dev/null 2>&1; QDPID=$!; disown "$QDPID"

# because of using root anyway, so set directly USER=root
USERNAME=$(whoami)
echo $QDPID > /tmp/$USERNAME/$HOSTNAME/qis-qdpid
echo ""

exec $SHELL
