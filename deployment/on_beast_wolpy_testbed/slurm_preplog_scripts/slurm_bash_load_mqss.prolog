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

# check QPU jobs
VAR_GRES=$(scontrol show job $SLURM_JOB_ID | grep "qpu:")

if [[ "$VAR_GRES" == *qpu* ]]
then
  # create log file along with the prolog script
  mkdir -p /tmp/slurm_jobs

  # direct job information out to the logfile
  # echo "Detected job with QPU requirement: $VAR_GRES" >> /tmp/slurm_jobs/prep_j$SLURM_JOB_ID.log
  echo "----------------------------------------" >  /tmp/slurm_jobs/prep_j$SLURM_JOB_ID.log
  echo "SLURM PROLOG SCRIPT: ALLOC              " >> /tmp/slurm_jobs/prep_j$SLURM_JOB_ID.log
  echo "Log info of the job: ID=$SLURM_JOB_ID   " >> /tmp/slurm_jobs/prep_j$SLURM_JOB_ID.log
  echo "User submitted the job: $SLURM_JOB_USER " >> /tmp/slurm_jobs/prep_j$SLURM_JOB_ID.log
  echo "----------------------------------------" >> /tmp/slurm_jobs/prep_j$SLURM_JOB_ID.log

  # time when loading mqss
  DATELOG=$(date -u)
  echo "Start_time: load mqss - $DATELOG" >> /tmp/slurm_jobs/prep_j$SLURM_JOB_ID.log

  # loading mqss via bash script
  USERNAME=root
  # USERNAME=$SLURM_JOB_USER
  # MKDIR_MQSS=$(mkdir -p /tmp/$USERNAME/$HOSTNAME/mqss)
  # CP_MQSS=$(cp /root/slurm-prep-scripts/mqss_scripts/load-* /root/slurm-prep-scripts/mqss_scripts/unload-* /tmp/$USERNAME/$HOSTNAME/mqss/)
  # /etc/slurm/mqss-prep-scripts/load-rabbitmq.sh
  LOAD_RABBITMQ=$(/usr/sbin/runuser -u $USERNAME -- /usr/bin/bash /etc/slurm/mqss-prep-scripts/load-rabbitmq.sh)
  LOAD_QDAEMON=$(/usr/sbin/runuser -u $USERNAME -- /usr/bin/screen -S sqdaemon -d -m /usr/bin/bash /etc/slurm/mqss-prep-scripts/load-qdaemon.sh)
  echo "LOAD_RABBITMQ: $LOAD_RABBITMQ" >> /tmp/slurm_jobs/prep_j$SLURM_JOB_ID.log 2>&1
  echo "LOAD_QDAEMON: $LOAD_QDAEMON" >> /tmp/slurm_jobs/prep_j$SLURM_JOB_ID.log 2>&1

  # sleep for while to make sure qdaemon get running
  sleep 3

  # time when unloading mqss
  DATELOG=$(date -u)
  echo "End_time: load mqss - $DATELOG" >> /tmp/slurm_jobs/prep_j$SLURM_JOB_ID.log

  # time to run the user application
  DATELOG=$(date -u)
  echo "Run user application at $DATELOG" >> /tmp/slurm_jobs/prep_j$SLURM_JOB_ID.log
  echo "----------------------------------------" >> /tmp/slurm_jobs/prep_j$SLURM_JOB_ID.log
  echo " " >> /tmp/slurm_jobs/prep_j$SLURM_JOB_ID.log

# else
  # do nothing
  # mkdir -p /tmp/slurm_jobs
  # echo "Job without QPU requirement | Check: $VAR_GRES" >> /tmp/slurm_jobs/prep_j$SLURM_JOB_ID.log
fi

# -----------------------------------------------------
# END: QIS MQSS load and unload - QPU connection
# -----------------------------------------------------
