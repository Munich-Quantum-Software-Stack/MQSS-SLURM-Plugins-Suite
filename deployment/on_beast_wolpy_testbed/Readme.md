## Deploy on 4 wolpy nodes as a slurm cluster testbed
(Before going to merge with the whole beast system)

1. Environment setup
- wolpy05: login node
- wolpy06, wolpy07, wolpy08: HPC compute nodes

2. Create slurm.conf on wolpy05, then sync it with the other nodes

```Bash
#SlurmctldHost=beast-gw
SlurmctldHost=wolpy05
#
MpiDefault=none
ProctrackType=proctrack/cgroup
Prolog=/etc/slurm/slurm.prolog
ReturnToService=2
SlurmctldPidFile=/var/run/slurm/slurmctld.pid
SlurmctldPort=6817
SlurmdPidFile=/var/run/slurm/slurmd.pid
SlurmdPort=6818
SlurmdSpoolDir=/var/spool/slurmd
SlurmUser=slurm
SlurmdUser=root
StateSaveLocation=/var/spool/slurm-state
SwitchType=switch/none
TaskPlugin=task/affinity,task/cgroup
#
UsePAM=1
LaunchParameters=disable_send_gids
#
#
# TIMERS
InactiveLimit=0
KillWait=30
MinJobAge=300
SlurmctldTimeout=120
SlurmdTimeout=300
Waittime=0
#
#
# SCHEDULING
SchedulerType=sched/backfill
SelectType=select/cons_tres
SelectTypeParameters=CR_Core
#
#
# LOGGING AND ACCOUNTING
AccountingStorageType=accounting_storage/slurmdbd
AccountingStorageHost=localhost
ClusterName=beast
JobCompLoc=/var/log/slurm/JobComp.log
JobCompType=jobcomp/filetxt
JobAcctGatherFrequency=30
JobAcctGatherType=jobacct_gather/none
SlurmctldDebug=info
SlurmctldLogFile=/var/log/slurm/slurmctld.log
SlurmdDebug=info
SlurmdLogFile=/var/log/slurm/slurmd.log
#
# COMPUTE NODES
NodeName=wolpy[06-08] CPUs=144 Boards=1 SocketsPerBoard=2 CoresPerSocket=36 ThreadsPerCore=2 RealMemory=200000
PartitionName=wolpyqpu Nodes=wolpy[06-08] State=UP MaxTime=7-0 OverSubscribe=EXCLUSIVE
```

3. Create slurmdbd.conf on wolpy05

```Bash
AuthType=auth/munge
DbdAddr=localhost
DbdHost=localhost
DbdPort=7031 # maybe should open this port on wolpy05
SlurmUser=slurm
DebugLevel=verbose
# log and pid files
LogFile=/var/log/slurm/slurmdbd.log
PidFile=/var/run/slurm/slurmdbd.pid
StorageType=accounting_storage/mysql
StorageHost=localhost
# StorageLoc=slurm_acct_db
StoragePass=password
StorageUser=slurm
```

4. Create files and folders related to slurm configuration

```Bash
/var/run/slurm/slurmdbd.pid
/var/run/slurm/slurmctld.pid
/var/run/slurm/slurmd.pid
/var/spool/slurmd
/var/spool/slurm-state
/var/log/slurm/JobComp.log
/var/log/slurm/slurmdbd.log
/var/log/slurm/slurmctld.log
/var/log/slurm/slurmd.log
```

5. Install mysql (mariadb version 15) on the master node and configure the database
- For example: yum install mariadb-server
- Create database

```Bash
 # switch to root
    sudo –I (login as root; su command may also be used)
    # create the database
    mysql
    grant all on slurm_acct_db.* TO 'slurm'@'localhost' identified by 'password' with grant option; 
    create database slurm_acct_db;
    exit
```

- There might an issue with only installing mariadb-server, we should install mariadb-devel
- Make sure the path of this library visible
- Configure SLURM and re-compile it on wolpy05

```Bash
export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64:$LD_LIBRARY_PATH
./configure --enable-debug --prefix=/usr/local --with-pmix=/usr/local --sysconfdir=/etc/slurm
```

- Restart slurmctld and slurmdbd service on wolpy, then check the status

6. Sync the slurm.conf file on wolpy05 with compute nodes: wolpy06, wolpy07, wolpy08
- The original slurm.conf on wolpy compute nodes
```Bash
SlurmctldHost=beast-gw
#
MpiDefault=none
#MpiParams=ports=#-#
#PluginDir=
#PlugStackConfig=
#PrivateData=jobs
ProctrackType=proctrack/cgroup
Prolog=/etc/slurm/slurm.prolog
#PrologFlags=
#PrologSlurmctld=
#PropagatePrioProcess=0
#PropagateResourceLimits=
#PropagateResourceLimitsExcept=
#RebootProgram=
ReturnToService=2
SlurmctldPidFile=/var/run/slurm/slurmctld.pid
SlurmctldPort=6817
SlurmdPidFile=/var/run/slurm/slurmd.pid
SlurmdPort=6818
SlurmdSpoolDir=/var/spool/slurmd
SlurmUser=slurm
SlurmdUser=root
#SrunEpilog=
#SrunProlog=
StateSaveLocation=/var/spool/slurm-state
SwitchType=switch/none
#TaskEpilog=
# TaskPlugin=task/affinity
TaskPlugin=task/affinity,task/cgroup
#TaskProlog=
#TopologyPlugin=topology/tree
#TmpFS=/tmp
#TrackWCKey=no
#TreeWidth=
#UnkillableStepProgram=
#UsePAM=0
UsePAM=1
LaunchParameters=disable_send_gids
#
#
# TIMERS
#BatchStartTimeout=10
#CompleteWait=0
#EpilogMsgTime=2000
#GetEnvTimeout=2
#HealthCheckInterval=0
#HealthCheckProgram=
InactiveLimit=0
KillWait=30
#MessageTimeout=10
#ResvOverRun=0
MinJobAge=300
#OverTimeLimit=0
SlurmctldTimeout=120
SlurmdTimeout=300
#UnkillableStepTimeout=60
#VSizeFactor=0
Waittime=0
#
#
# SCHEDULING
#DefMemPerCPU=0
#MaxMemPerCPU=0
#SchedulerTimeSlice=30
SchedulerType=sched/backfill
SelectType=select/cons_tres
SelectTypeParameters=CR_Core
#
# LOGGING AND ACCOUNTING
#AccountingStorageEnforce=0
#AccountingStorageHost=
#AccountingStoragePass=
#AccountingStoragePort=
AccountingStorageType=accounting_storage/slurmdbd
AccountingStorageHost=localhost
#AccountingStorageUser=
#AccountingStoreJobComment=YES
ClusterName=beast
#DebugFlags=
#JobCompHost=
JobCompLoc=/var/log/slurm/JobComp.log
#JobCompPass=
#JobCompPort=
JobCompType=jobcomp/filetxt
#JobCompUser=
#JobContainerType=job_container/none
JobAcctGatherFrequency=30
JobAcctGatherType=jobacct_gather/none
SlurmctldDebug=info
SlurmctldLogFile=/var/log/slurm/slurmctld.log
SlurmdDebug=info
SlurmdLogFile=/var/log/slurm/slurmd.log
#SlurmSchedLogFile=
#SlurmSchedLogLevel=
#

```

- Now, update it and keep it changed as follows
```Bash
SlurmctldHost=wolpy05
...

GresTypes=qpu
NodeName=wolpy[06-08] Gres=qpu:1 CPUs=144 Boards=1 SocketsPerBoard=2 CoresPerSocket=36 ThreadsPerCore=2 RealMemory=200000
PartitionName=wolpyqpu Nodes=wolpy[06-08] State=UP MaxTime=7-0 OverSubscribe=EXCLUSIVE

```

- Add the gres.conf file on each node
``` Bash
# Configure 1 general QPU per node
AutoDetect=off
Name=qpu Type=general Count=1
```