#!/bin/sh

#
# slurm.prolog, based on CM3 prolog
#

# this script
_progname=`basename $0`

# prepare logger call
_logger="logger -i -t $_progname -- SLURM:"

# get intention
case "$_progname" in
  *prolog* )
    _logue_type=prolog
    ;;
  *epilog* )
    _logue_type=epilog
    ;;
  * )
    $_logger "fatal: wrong link name"
    exit 255
    ;;
esac

# set test variable
# export FOOBAR=`getent passwd $USER | cut -f6 -d\:`

# re-set HOME
[ -z "$HOME" -a ! -z "$USER" ] && \
  export HOME=`getent passwd $USER | cut -f6 -d\:`

# check SLURM configuration
DEFAULT_SLURM_CONF=/etc/slurm/slurm.conf
[ -z "$SLURM_CONF" -a -f $DEFAULT_SLURM_CONF ] && \
  export SLURM_CONF=$DEFAULT_SLURM_CONF

# check SLURM_CONF
if [ -z "$SLURM_CONF" ]
then
  $_logger "fatal: variable SLURM_CONF not set (and $DEFAULT_SLURM_CONF not found)"
  exit 1
fi

# get clustername
[ -z "$SLURM_CLUSTERNAME" ] && \
  export SLURM_CLUSTERNAME=`egrep ^ClusterName= $SLURM_CONF | cut -f2 -d\= | sed -e 's/[ \t]*\#.*//'`
if [ -z "$SLURM_CLUSTERNAME" ]
then
  $_logger "fatal: SLURM_CLUSTERNAME not set (and not found in $SLURM_CONF)"
  exit 2
fi

# read sysconfig
_sysconf=/etc/sysconfig/slurm
if [ -r $_sysconf ]
then
  . $_sysconf
  [ $? -ne 0 ] && $_logger "fatal: error sourcing $_sysconf" && exit 3
fi

#
# call clustername specific prologue resp. epilogue
#
# _rc=0
# for _dir in `dirname $_progname` `dirname $SLURM_CONF` /etc/slurm \
#             `echo "$SLURM_UTILS_PATH" | sed -e 's/:/ /g'`
# do
#   _logue=${_dir}/slurm-${SLURM_CLUSTERNAME}.${_logue_type}
#   [ ! -f $_logue ] && continue
# 
#   $_logue
# 
#   _rc=$?
#   break
# done

jobscript=`scontrol show job=$SLURM_JOB_ID | grep Command`
`scontrol update job=$SLURM_JOB_ID AdminComment="$jobscript"`


sync; echo 3 > /proc/sys/vm/drop_caches


# clean up
unset _dir _logue _logue_type _logger _progname _sysconf


# -----------------------------------------------------
# START: QIS MQSS load and unload - QPU connection
# -----------------------------------------------------
# create log file along with the prolog script
mkdir -p /tmp/slurm_jobs

# direct job information out to the logfile
echo "----------------------------------------" >  /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log
echo "SLURM PROLOG SCRIPT: ALLOC              " >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log
echo "Log info of the job: ID=$SLURM_JOB_ID   " >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log
echo "User submitted the job: $SLURM_JOB_USER " >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log
echo "----------------------------------------" >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log

# check QPU jobs
VAR_GRES=$(scontrol show job $SLURM_JOB_ID | grep "qpu:")

if [[ "$VAR_GRES" == *qpu* ]]
then
  echo "Detected job with QPU requirement: $VAR_GRES" >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log

  # time start loading mqss
  DATELOG=$(date -u)
  echo "Start_time: load mqss - $DATELOG" >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log
  
  # loading rabbitmq using python script
  PYLOAD_RMQ=$(/usr/bin/python /root/slurm-prep-scripts/mqss_scripts/py_run_load-rabbitmq.py)
  echo "Load MQSS using Python: $PYLOAD_RMQ" >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log

  # loading qdaemon
  sleep 2

  # time end loading mqss
  DATELOG=$(date -u)
  echo "End_time: load mqss - $DATELOG" >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log
  
  # time run the user application
  DATELOG=$(date -u)
  echo "Run user application at time $DATELOG" >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log

else
  echo "Job without QPU requirement | Check: $VAR_GRES" >> /tmp/slurm_jobs/pro_j$SLURM_JOB_ID.log
fi

# -----------------------------------------------------
# END: QIS MQSS load and unload - QPU connection
# -----------------------------------------------------
