## SLURM Plugin for defining GRES_QPU and dispatching QPU jobs

Plugins to control quantum resources within the SLURM workload manager. In this context, QPU is configured as an accelerator like GPU.

This project repo is mainly organized as follows.
* `/deployment`: instructions for installing and configuring SLURM on virtual machines.
* `/src`: contains $2$ sub-folders, where HPC-QC plugins can be implemented with SLURM Prolog/Epilog, or with SLURM SPANK.
    * `/prep_plugin`: Prolog and Epilog scripts to control SLURM before or after quantum jobs are submitted.
    * `/spank_plugin`: SPANK plugins that can be used to control SLURM to handle quantum jobs.
* `/mqss_scripts`: related scripts to create a connection to the MQSS Quantum Resource Manager, e.g., load/unload quantum daemon, offload quantum tasks to QPU.

Creating external plugins by Prolog/Epilog or SPANK is flexible and has little impact on the SLURM source code. This is also easy to plug in and out.


### For a testbed deployment, we can use
* 2 Virtual Machines: for example, we can name `slurm_master` and `slurm_worker`.
* OS: Ubuntu 22.04
* Shared working directory: NFS can be used for simple tests, e.g., `/home/ubuntu/shared_nfs_slurm`. Here, `ubuntu` is the test user and `shared_nfs_slurm` is the mount point between two nodes (or 2 VMS).
* Jobs should be submitted from the master node (`slurm_master`)
* SLURM Setup: can be built from source; the tested version is slurm-23.11 (https://github.com/SchedMD/slurm/tree/slurm-23.11).  The setup can be found in more detail at `/deployment`.

### Contributing
Feel free to open issues or submit pull requests.