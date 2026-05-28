# Deployment

\tableofcontents

This page covers what needs to be configured on a real cluster to make the plugins work end-to-end.
The reference testbed uses two Ubuntu 22.04 nodes — `slurm_master` (controller + login) and
`slurm_worker` (compute) — but the same steps apply to larger clusters.

## 1. Node Connectivity

### `/etc/hosts`

Each node must be able to resolve the other by hostname. Add both entries on every node:

```
10.195.1.xy1  slurmmaster
10.195.1.xy2  slurmnode1
```

### SSH without password

Required for SLURM to communicate between nodes:

```bash
# on master:
ssh-keygen
ssh-copy-id ubuntu@slurmnode1

# on compute node:
ssh-keygen
ssh-copy-id ubuntu@slurmmaster
```

### NFS shared directory

A shared directory is used to distribute SPANK plugins, scripts, and config across nodes.

```bash
# --- on master (server) ---
sudo apt install -y nfs-kernel-server
sudo mkdir -p /home/ubuntu/shared_nfs_slurm
# add to /etc/exports:
echo "/home/ubuntu/shared_nfs_slurm  *(rw,sync,no_subtree_check,no_root_squash)" \
  | sudo tee -a /etc/exports
sudo exportfs -a
sudo systemctl restart nfs-kernel-server

# --- on compute node (client) ---
sudo apt install -y nfs-common
sudo mkdir -p /home/ubuntu/shared_nfs_slurm
sudo mount slurmmaster:/home/ubuntu/shared_nfs_slurm /home/ubuntu/shared_nfs_slurm
# to persist across reboots, add to /etc/fstab:
echo "slurmmaster:/home/ubuntu/shared_nfs_slurm  /home/ubuntu/shared_nfs_slurm  nfs  defaults  0 0" \
  | sudo tee -a /etc/fstab
```

## 2. SLURM Configuration

### `slurm.conf`

Key parameters relevant to QPU integration. Place this on all nodes at `/etc/slurm/slurm.conf`
(the file must be identical on controller and compute nodes):

```
SlurmctldHost=slurmmaster

# Process tracking (required for cgroup-based resource control)
ProctrackType=proctrack/cgroup
TaskPlugin=task/affinity,task/cgroup

# Prolog/Epilog hooks (only needed if using the prep_plugin approach)
Prolog=/home/ubuntu/shared_nfs_slurm/mqss-scripts/prolog_init_qdaemon.sh
Epilog=/home/ubuntu/shared_nfs_slurm/mqss-scripts/epilog_fina_qdaemon.sh

# GRES for QPU resource tracking (optional, for accounting)
GresTypes=qpu

# Scheduler
SchedulerType=sched/backfill
SelectType=select/cons_tres
SelectTypeParameters=CR_Core

# Accounting (optional)
AccountingStorageType=accounting_storage/slurmdbd
AccountingStorageHost=localhost
ClusterName=mycluster

# Logging
SlurmctldLogFile=/var/log/slurm/slurmctld.log
SlurmdLogFile=/var/log/slurm/slurmd.log

# Compute nodes
NodeName=slurmnode1 CPUs=8 RealMemory=16000 State=UNKNOWN
PartitionName=qpu Nodes=slurmnode1 Default=YES MaxTime=INFINITE State=UP
```

### `slurmdbd.conf` (accounting daemon, on master only)

```
AuthType=auth/munge
DbdHost=localhost
DbdPort=7031
SlurmUser=slurm
LogFile=/var/log/slurm/slurmdbd.log
PidFile=/var/run/slurm/slurmdbd.pid
StorageType=accounting_storage/mysql
StorageHost=localhost
StoragePass=password
StorageUser=slurm
```

### Required directories and permissions

Run on every node:

```bash
sudo mkdir -p /var/spool/slurmd /var/spool/slurm-state \
              /var/log/slurm /run/slurm

sudo chown -R slurm:slurm /var/spool/slurmd /var/spool/slurm-state \
                           /var/log/slurm /run/slurm
sudo chmod 755 /var/spool/slurmd /var/log/slurm
```

### `cgroup.conf`

```bash
sudo echo "CgroupMountpoint=/sys/fs/cgroup" > /etc/slurm/cgroup.conf
```

## 3. SPANK Plugin Registration

After installing the `.so` files (see [Getting Started](getting_started.md)), register them in
`/etc/slurm/plugstack.conf` on every compute node:

```
# /etc/slurm/plugstack.conf
required /home/ubuntu/shared_nfs_slurm/spank_plugins/shared_plugins/load_unload_rabbitmq.so
required /home/ubuntu/shared_nfs_slurm/spank_plugins/shared_plugins/load_unload_mqss.so
```

Use `required` to fail the job if the plugin cannot be loaded, or `optional` to continue without it.

Restart `slurmd` on compute nodes after any change to `plugstack.conf`:

```bash
sudo systemctl restart slurmd
```

The SPANK plugins and Prolog/Epilog hooks to start and stop RabbitMQ and `qdaemon`.

## 5. RabbitMQ

Install and enable RabbitMQ on the compute node (it is started per-job by the plugin):

```bash
sudo apt install -y rabbitmq-server
sudo systemctl disable rabbitmq-server   # do not auto-start; SPANK manages it
```

To verify RabbitMQ starts and stops correctly, use the test scripts in
[`test/test_rabbitmq/`](../test/test_rabbitmq/).

## 6. `qdaemon`

Install the quantum daemon in a Python environment accessible to the job user. The daemon is
started by the prolog script and stopped by the epilog script. A minimal start command:

```bash
py_qdaemon --config-file /path/to/qd-config.json &
```

Refer to the `py_qdaemon` package documentation for the config file format and available backends.

## 7. Starting SLURM Services

### On the master node

```bash
sudo systemctl enable --now munge slurmctld slurmdbd
```

### On each compute node

```bash
sudo systemctl enable --now munge slurmd
```

### Verify

```bash
# from the master node:
sinfo          # should show partition and node state
srun hostname  # run a test job
```

## Troubleshooting

| Symptom | Where to look |
|---|---|
| Jobs stuck in PD state | `scontrol show job <id>`, check `slurmctld.log` |
| SPANK plugin not loading | `/var/log/slurm/slurmd.log`, check `plugstack.conf` path |
| RabbitMQ not starting | `/tmp/slurm_jobs/spank_log.txt` (written by the plugin) |
| Prolog/Epilog not running | Verify `Prolog=` / `Epilog=` paths in `slurm.conf`, check script permissions |
| Munge errors | `sudo systemctl status munge`, ensure the same munge key on all nodes |