## Deploy SLURM on virtual machines as a testbed cluster

1. Environment setup
- Ubuntu 22.04
- Should check, install, and update necessary packages: `apt update` and install `build-essential`
- Used VMs:
    + Master node: hostname `slurmmaster`, IP `10.195.1.135`
    + Compute node: hostnam `slurmnode1`, IP `10.195.1.134`
- Declare the IP addresses of two nodes in `/etc/hosts` to know the IP of each other
- Setup SSH without passwords between two nodes:
    + On master: `$ ssh-keygen && ssh-copy-id ubuntu@slurmnode1`
    + On compute node: `$ ssh-keygen && ssh-copy-id ubuntu@slurmmaster`
- Configure NFS mount between master and compute node

``` Bash
    # --------------------------------
    # On the master node:
    # --------------------------------
    # install nfs server package
    sudo apt install nfs-kernel-server
    # create the shared folder and change the permission as well as owner if necessary
    mkdir ~/slurm_space
    # configure export file at /etc/exports
    /home/ubuntu/slurm_space    192.168.1.31(rw,sync,no_subtree_check)
    # restart the service
```

``` Bash
    # --------------------------------
    # On the compute node:
    # --------------------------------
    # install nfs common
    sudo apt install nfs-common
    # create the shared folder and change the permission as well as owner if necessary
    mkdir ~/slurm_space
    # run mount command
    sudo mount master-node:/home/ubuntu/slurm_space /home/ubuntu/slurm_space
    # configure automount when the system is reboot at the file /etc/fstab
    # add the line
    master-node:/home/ubuntu/slurm_space /home/ubuntu/slurm_space nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0
```

2. Setup munge and related accounts on the master node

- Should create user and group user for **slurm** and **munge** first
``` Bash
    sudo adduser -u 1001 munge --disabled-password --gecos ""
    sudo adduser -u 1002 slurm --disabled-password --gecos ""

    # Where, `--gecos` to skip asking for finger information when we create new users.
```

- Install and configure MUNGE (Authentication service for creating and validating user credentials)
``` Bash
    # install munge and deps
    sudo apt-get install libmunge-dev libmunge2 munge

    # enable and start munge
    sudo systemctl enable munge
    sudo systemctl start munge

    # check munge if everything is ok
    munge -n | unmunge | grep STATUS

    # Note: the key of munge is at /etc/munge/munge.key by default
    # we will need it for the compute node;
    # copy it to the compute node, and move it to the same folder on
    # the compute node (/etc/munge/) after MUNGE is installed on compute node

    # Note: pay attention with the permission of the munge.key file when we try 
    # to copy or move it around. For example,
    #   + sudo chown munge:munge .../munge.key (to change the owner of the file)
    #   + sudo chmod 644 .../munge.key (to enable copying/moving)
    # And maybe change the permission/owner back when it is located in the folder, /etc/munge
```

- The script of installing and configuring MUNGE is at `/config_scripts/install_config_munge_master.sh` as a reference.

3. Setup munge and related accounts on the compute node

- Should create user and group user for **slurm** and **munge** first
``` Bash
    sudo adduser -u 1001 munge --disabled-password --gecos ""
    sudo adduser -u 1002 slurm --disabled-password --gecos ""
```

``` Bash
    # install the packages
    sudo apt-get install libmunge-dev libmunge2 munge
    # copy the munge key from the master node
    sudo cp /home/admin/shared/slurm_storage/munge_key/munge.key /etc/munge/
    # change the ownership and permission
    sudo chown munge:munge /etc/munge/munge.key
    sudo chmod 400 /etc/munge/munge.key
    # enable and start the munge service
    sudo systemctl enable munge
    sudo systemctl start munge
    # check munge (optional)
    munge -n | unmunge | grep STATUS
```

4. Install slurm and configure slurm on the master node

- Install mariadb on the master node:
``` Bash
    # install the package from default distribution
    sudo apt install mariadb-server mariadb-client libmariadb-dev
```

- Install slurm from source
    + Because the current idea is: using a shared folder /slurm_space for both master and compute nodes, so, we just need to compile and install slurm from one side
    + However, the install location would be /usr/local, therefore, at the step, make install, slurm on each node will be working separately.
    + In the extracted folder of slurm scr, we do
``` Bash
    # create the default config folder of slurm first
    sudo mkdir  /etc/slurm
    # run config
    ./configure --enable-debug --prefix=/usr/local --sysconfdir=/etc/slurm
    # then make and make install
    make
    sudo make install
```

- Create a database with mysql
``` Bash
    # switch to root
    sudo –I (login as root; su command may also be used)
    # create the database
    mysql
    grant all on slurm_acct_db.* TO 'slurm'@'localhost' identified by 'admin' with grant option; 
    create database slurm_acct_db;
    exit
```

- Configure the database file for slurm
``` Bash
    sudo mkdir /etc/slurm # if we install from the linux distribution, the folder will be automatically created
    sudo vim /etc/slurm/slurmdbd.conf # add the below lines shown in green in the file and save
```

```Bash
# ------------------------------------------
# The content of the database config
# ------------------------------------------
AuthType=auth/munge
# should keep the config as below, otherwise on the VMs, when starting slurmdbd, it gets the problem
# slurmdbd: error: mysql_real_connect failed: 2002
DbdAddr=IP-ADDR
DbdHost=localhost
DbdPort=6819
SlurmUser=slurm
DebugLevel=4
# log and pid files
LogFile=/var/log/slurm/slurmdbd.log
PidFile=/run/slurm/slurmdbd.pid
StorageType=accounting_storage/mysql
StorageHost=localhost
StorageLoc=slurm_acct_db
StoragePass=admin
StorageUser=slurm
# setting database purge parameters
PurgeEventAfter=12months
PurgeJobAfter=12months
PurgeResvAfter=2months
PurgeStepAfter=2months
PurgeSuspendAfter=1month
PurgeTXNAfter=12months
PurgeUsageAfter=12months
```

- Install `ufw` and allow the ports for slurm
```Bash
    sudo ufw allow 6817
    sudo ufw allow 6818
    sudo ufw allow 6819
```

- Change the ownership for the database config files to slurm
```Bash
    chown slurm:slurm /etc/slurm/slurmdbd.conf
    chmod 600 /etc/slurm/slurmdbd.conf
```

- Create and configure the slurm.conf file
```Bash
# slurm.conf file generated by configurator easy.html.
# Put this file on all nodes of your cluster.
# See the slurm.conf man page for more information.
#
ClusterName=slurmtestbed
SlurmctldHost=slurmmaster
#
#MailProg=/bin/mail
#MpiDefault=
#MpiParams=ports=#-#
ProctrackType=proctrack/cgroup
ReturnToService=1
SlurmctldPidFile=/run/slurm/slurmctld.pid
#SlurmctldPort=6817
SlurmdPidFile=/run/slurm/slurmd.pid
#SlurmdPort=6818
SlurmdSpoolDir=/var/spool/slurmd
SlurmUser=slurm
#SlurmdUser=root
StateSaveLocation=/var/spool/slurmctld
#SwitchType=
TaskPlugin=task/affinity,task/cgroup
#
#
# TIMERS
#KillWait=30
#MinJobAge=300
#SlurmctldTimeout=120
#SlurmdTimeout=300
#
#
# SCHEDULING
SchedulerType=sched/backfill
SelectType=select/cons_tres
#
#
# LOGGING AND ACCOUNTING
#AccountingStorageType=
#JobAcctGatherFrequency=30
JobAcctGatherType=jobacct_gather/cgroup
SlurmctldDebug=debug
SlurmctldLogFile=/var/log/slurm/slurmctld.log
SlurmdDebug=debug
SlurmdLogFile=/var/log/slurm/slurmd.log
#
#
# COMPUTE NODES
GresTypes=qpu
NodeName=slurm-node1 NodeAddr=slurm-node1 Gres=qpu:1 CPUs=1 RealMemory=4069 Sockets=1 CoresPerSocket=1 ThreadsPerCore=1 State=UNKNOWN
PartitionName=testbed Nodes=ALL Default=YES MaxTime=INFINITE State=UP
```

- Change the ownership for the config file of slurm
```Bash
    sudo chown slurm:slurm /etc/slurm/slurm.conf
    sudo chmod 644 /etc/slurm/slurm.conf
```

- Create some folders for the log of slurm
```Bash
    # slurm pid files and folders: pid files
    sudo mkdir /run/slurm
    # state save files for slurmd and slurmctrld
    sudo mkdir /var/spool/slurmd
    sudo mkdir /var/spool/slurmctld
    # log files
    sudo mkdir /var/log/slurm

    # change the ownership for all folders above
    sudo chown -R slurm:slurm /run/slurm /var/spool/slurmd /var/spool/slurmctld /var/log/slurm
    sudo chmod -R 755 /var/spool/slurmctld /var/spool/slurmd /var/log/slurm

    # create initial files for slurm logs
    sudo touch /var/log/slurm/slurmctld.log /var/log/slurm/slurm_jobacct.log /var/log/slurm/slurm_jobcomp.log
```

- Create the slurmctld service
```Bash
    # ------------------------------------------------
    sudo vim /usr/lib/systemd/system/slurmctld.service
    # ------------------------------------------------
    [Unit]
    Description=Slurm controller daemon
    After=network-online.target munge.service
    Wants=network-online.target
    ConditionPathExists=/etc/slurm/slurm.conf
    Documentation=man:slurmctld(8)

    [Service]
    Type=simple
    EnvironmentFile=-/etc/default/slurmctld
    ExecStart=/usr/local/sbin/slurmctld -D -s $SLURMCTLD_OPTIONS
    ExecReload=/bin/kill -HUP $MAINPID
    PIDFile=/run/slurm/slurmctld.pid
    LimitNOFILE=65536
    TasksMax=infinity

    [Install]
    WantedBy=multi-user.target

    # ------------------------------------------------
    sudo vim /usr/lib/systemd/system/slurmdbd.service
    # ------------------------------------------------
    [Unit]
    Description=Slurm DBD accounting daemon
    After=network-online.target munge.service mysql.service mysqld.service mariadb.service
    Wants=network-online.target
    ConditionPathExists=/etc/slurm/slurmdbd.conf
    Documentation=man:slurmdbd(8)

    [Service]
    Type=simple
    EnvironmentFile=-/etc/default/slurmdbd
    ExecStart=/usr/local/sbin/slurmdbd -D -s $SLURMDBD_OPTIONS
    ExecReload=/bin/kill -HUP $MAINPID
    PIDFile=/run/slurm/slurmdbd.pid
    LimitNOFILE=65536
    TasksMax=infinity

    [Install]
    WantedBy=multi-user.target
```

- Configure the cgroup under root permission
```Bash
    sudo echo CgroupMountpoint=/sys/fs/cgroup >> /etc/slurm/cgroup.conf
    # The content of this file should be
    
    # Config cgroup for slurm
    CgroupMountpoint=/sys/fs/cgroup

    #CgroupAutomount=yes
    #CgroupReleaseAgentDir="/etc/slurm/cgroup"

    ConstrainCores=yes
    ConstrainDevices=yes
    #TaskAffinity=yes
    ConstrainRAMSpace=yes
    #ConstrainSwapSpace=yes
    MaxRAMPercent=95
    AllowedSwapSpace=0
    AllowedRAMSpace=200
    MemorySwappiness=0
```

- Test slurm on the master node
```Bash
    slurmd -C

    sudo systemctl daemon-reload

    sudo systemctl enable slurmdbd
    sudo systemctl start slurmdbd

    sudo systemctl enable slurmctld
    sudo systemctl start slurmctld
```

5. Install and configure SLURM on the compute node

- Install mariadb on the master node:
``` Bash
    # install the package from default distribution
    sudo apt install mariadb-server mariadb-client libmariadb-dev
```

- As we use the shared nfs folder between two nodes, so the compiled slurm src is already there
- We do not need to compile it again, we can just "make install" on the compute node. However, we should create the folders below first
- Just to make sure that slurm is installed consistently with the master node
``` Bash
    # copy the config files from the mast node to the compute node and move them to /etc/slurm
    # please pay attention on the ownership and permission

    # create some necessary folders
    sudo mkdir /etc/slurm

    sudo mkdir /var/spool/slurmd 
    sudo chown -R slurm:slurm /var/spool/slurmd
    sudo chmod 755 /var/spool/slurmd
    
    sudo mkdir /var/log/slurm/
    sudo chown -R slurm:slurm /var/log/slurm
    sudo chmod 755 /var/log/slurm
    sudo touch /var/log/slurm/slurmd.log
    sudo chown slurm:slurm /var/log/slurm/slurmd.log
    
    sudo mkdir /run/slurm
    sudo chown -R slurm:slurm /run/slurm
    sudo chmod -R 770 /run/slurm
    sudo touch /run/slurm/slurmd.pid
    sudo chmod 770 /run/slurm/slurmd.pid
    sudo chown slurm:slurm /run/slurm/slurmd.pid
```

- Create a slurm config file (but not sure why we need this)
``` Bash
d /run/slurm 0770 slurm slurm -
d /var/run/slurm 0755 slurm slurm -
d /var/log/slurm 0755 slurm slurm -
d /var/spool/slurm 0755 slurm slurm -
```

- Install slurm: make install

- Copy the slurm.conf file from the master node to the compute node
``` Bash
# copy the file via scp
sudo scp /etc/slurm/slurm.conf compute-node:/etc/slurm
# change the ownership of the file
sudo chown slurm:slurm /etc/slurm/slurm.conf
```

- Create the slurmd.service
```Bash
    [Unit]
    Description=Slurm node daemon
    After=munge.service network-online.target remote-fs.target
    Wants=network-online.target
    ConditionPathExists=/etc/slurm/slurm.conf
    Documentation=man:slurmd(8)

    [Service]
    Type=simple
    EnvironmentFile=-/etc/default/slurmd
    ExecStart=/usr/local/sbin/slurmd -D -s $SLURMD_OPTIONS
    ExecReload=/bin/kill -HUP $MAINPID
    PIDFile=/run/slurm/slurmd.pid
    KillMode=process
    LimitNOFILE=131072
    LimitMEMLOCK=infinity
    LimitSTACK=infinity
    Delegate=yes
    TasksMax=infinity

    [Install]
    WantedBy=multi-user.target
```

- Configure the cgroup under root permission
```Bash
    sudo su
    echo CgroupMountpoint=/sys/fs/cgroup >> /etc/slurm/cgroup.conf
    # the content of this file should be

    # Config cgroup for slurm
    CgroupMountpoint=/sys/fs/cgroup

    #CgroupAutomount=yes
    #CgroupReleaseAgentDir="/etc/slurm/cgroup"

    ConstrainCores=yes
    ConstrainDevices=yes
    #TaskAffinity=yes
    ConstrainRAMSpace=yes
    #ConstrainSwapSpace=yes
    MaxRAMPercent=95
    AllowedSwapSpace=0
    AllowedRAMSpace=200
    MemorySwappiness=0
```

- Configure a gres.conf file for the QPU resource at /etc/slurm/
```Bash
    #Configure 1 QPU
    AutoDetect=off
    Name=qpu Type=iqm5 Count=1
```

- Test slurm on the master node
```Bash
    slurmd -C
    sudo systemctl daemon-reload
    sudo systemctl enable slurmd
    sudo systemctl start slurmd

    # Could be an error: Couldn't find the specified plugin name for cgroup/v2 looki>
    # compute-node slurmd[8524]: slurmd: error: cannot find cgroup plugin for cgroup/v2
    # we should install dbus-devel

    sudo apt install dbus dbus-user-session libdbus-1-dev linux-headers-generic

    # There could be another issue:
    # slurmd: debug:  slurm_recv_timeout at 0 of 4, recv zero bytes
    # compute-node slurmd[15929]: slurmd: debug:  Unable to register with slurm controller ...
    # For this, check the ownership and permission of the config files
    #   sudo ls -la /etc/slurm/
    #   sudo ls -la /etc/munge/
    # where, importantly, the munge.key file on the master node should have 'rw' permission
    # but, the one on the compute node should only have 'r' permission

    # Make sure the permission of munge.key on the compute node
    sudo chmod 400 /etc/munge/munge.key
    
```

6. Others
- Some notes about creating unit service files.
- These would be needed for start, stop, or restart slurm processes as a service

``` Bash
    invoke-rc.d: policy-rc.d denied execution of start.
    Created symlink /etc/systemd/system/multi-user.target.wants/slurmdbd.service → /lib/systemd/system/slurmdbd.service.
    Processing triggers for libc-bin (2.35-0ubuntu3.6) ...
    # https://askubuntu.com/questions/1452839/configuring-mysql-for-slurm

    update-alternatives: using /usr/sbin/slurmctld-wlm to provide /usr/sbin/slurmctld (slurmctld) in auto mode
    invoke-rc.d: policy-rc.d denied execution of start.

    Created symlink /etc/systemd/system/multi-user.target.wants/slurmctld.service → /lib/systemd/system/slurmctld.service.
    Setting up slurmd (21.08.5-2ubuntu1) ...

    update-alternatives: using /usr/sbin/slurmd-wlm to provide /usr/sbin/slurmd (slurmd) in auto mode
    invoke-rc.d: policy-rc.d denied execution of start.

    Created symlink /etc/systemd/system/multi-user.target.wants/slurmd.service → /lib/systemd/system/slurmd.service.
    Setting up slurm-wlm (21.08.5-2ubuntu1) ...
```
