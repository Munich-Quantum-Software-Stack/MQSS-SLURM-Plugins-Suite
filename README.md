## SLURM Plugin for defining GRES_QPU and dispatching QPU jobs

Plugin to control quantum resources within SLURM-HPC workload manager. In this context, QPU is considered an accelerator like GPU.

Repository:
* `/deployment`: instructions of installing and configuring SLURM on virtual machines, docker containers
* `/src`: contains $2$ sub-folders, plugin with prolog and epilog, plugin with spank
    * `/prep_plugin`: prolog and epilog scripts to control SLURM before, after, or even jobs are executing.
    * `/spank_plugin`: spank plugins that are also used to control SLURM, even deeper when interfering SLURM.
* `/mqss_scripts`: related bash scripts to load, unload quantum components before a quantum task can be offloaded.
* `/test`: examples and tests for job submission with SLURM
* `/utils`: other useful scripts or codes


### Options to create an external plugin for SLURM

Prioritize the ways of SLURM intervention that are flexible, has little impact on SLURM source code, and is easy to plug-in and plug-out. There are two ways:
* Using Prolog/Epilog
* Using SPANK Plugin


### SLURM Setup

* Can build SLURM from source, the current used version is slurm-23.11 (https://github.com/SchedMD/slurm/tree/slurm-23.11)
* Details in `/deployment`


### Testbed Environment

* Deployed on LRZ Compute Cloud, 2 VMs, where `slurm_master` (10.195.1.135), `slurm_node1` (10.195.1.134)
* OS: Ubuntu 22.04
* Account: ubuntu (default)
* Working directory (shared between both nodes): `/home/ubuntu/shared_nfs_slurm`
* Test job submission: `/home/ubuntu/shared_nfs_slurm/test_job_submission` (example3 is quantum job)
* Jobs should be submitted from the master node (`slurm_master`)
* Util commands to check the SLURM status: `sinfo`, `squeue`


### SLURM-qdaemon Integration with Prolog and Epilog scripts

* Prolog and Epilog scripts should be declared in the `slurm.conf` file (SLURM configuration file) to work as expected. For example, in the testbed env, the `slurm.conf` file is at `/etc/slurm/slurm.conf`,

```Bash
#
# PROLOG
Prolog=/home/ubuntu/shared_nfs_slurm/prolog_scripts/prolog_init_qdaemon_with_script.sh
PrologFlags=Alloc
#
#
# EPILOG
Epilog=/home/ubuntu/shared_nfs_slurm/epilog_scripts/epilog_fina_qdaemon_with_script.sh
#
```

* Prolog script: `/prolog_scripts/prolog_init_qdaemon.sh`
    + PrologFlags=Alloc will force the prolog script to be executed at job allocation.
    + This problem runs at the stage when the job is allocated
    + Before the job is executed, the prolog will be run first; therefore, this script will be used to init qdaemon.

* Epilog script: `/epilog_scripts/epilog_fina_qdaemon.sh`
    + This epilog is run after job termination
    + It will stop qdaemon

### SPANK plugin 

* Tried to play around, sounds good to develop a plugin which controls slurmctld. However, need to investigate more.
* SPANK example: `/spank_plugins`
* After compiling, the SPANK plugins are dynamic libs (.so files). They could be saved and shared at `/home/ubuntu/shared_nfs_slurm/spank_plugins/shared_plugins`

### Job submission examples

* Go to the folder: `/test/job_submission`
* For instance, we can try to submit `example3`
    + Job description file: `example3.cmd`
    + Executable file: `hpc-provider-ex.py`
    + Command to submit: `sbatch example3.cmd`


### Notes/Others and Initial Ideas

Reasoning for simplicity on a single QPU:

- The QPU is a shared resource
- The plugin shall provide to SLURM a measure of "quantum availability"
- The plugin shall exploit [backfilling](https://slurm.schedmd.com/sched_config.html#backfill)
- `Quantum availability` shall convey the information on
    + Load, which is provided by the number of jobs running on the QPU 
    + Downtime, which includes calibration time

- The **target** is to have for each submitted classical job, a **quantum-job execution time** as predictable as possible.
- Classical jobs requiring quantum acceleration shall be scheduled according to QPU availabiliy:
    + submitted to execution when we know the QPU is available for calculation, not before.
    + connection to QRM
- The user shall know when jobs is going to be run (this since the waiting in queue could be much longer the execution time)

Code and branches organization:
- `slurm-master` is a push of the `master` branch of SLURM from https://github.com/SchedMD/slurm.git
- `dev/<initials>/<plugin-name>` is branched and rebased on `slurm-master` and contains the specific plugin development in the SLURM tree

