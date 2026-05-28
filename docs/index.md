# MQSS SLURM Plugins Suite

\tableofcontents

## Overview

The **MQSS SLURM Plugins Suite** is a collection of plugins for integrating Quantum Processing
Units (QPUs) into HPC workloads managed by [SLURM](https://slurm.schedmd.com). Quantum resources
are exposed to SLURM as co-processors (similar to GPUs via GRES), allowing standard job scripts to
request QPU time without changes to the SLURM source code.

Plugins are implemented via two SLURM extension mechanisms:

- **SPANK** — shared libraries (`.so`) loaded by `slurmd` at job boundaries, used to start and
  stop the quantum daemon and message broker automatically on each compute node.
- **Prolog/Epilog scripts** — shell scripts invoked by SLURM before and after each job, providing
  an alternative hook mechanism for the same lifecycle tasks.

Both approaches are modular: they can be enabled, disabled, or swapped without recompiling SLURM.

### Key Features

- Automatic start/stop of RabbitMQ and `qdaemon` at job prolog/epilog via SPANK or scripts.
- No modifications to SLURM source code — pure plugin interface.
- Tested on multi-node clusters (virtual machines and bare-metal) with SLURM 23.11.
- Includes example plugins, job submission scripts, and quantum benchmark tests.

## Architecture

```
+---------------------+
|   SLURM Controller  |  (slurm_master)
+---------------------+
          |
          |  job dispatch
          v
+---------------------+     +-----------------------------+
|   Compute Node      |<--->|  SPANK Plugin (.so)         |
|   (slurm_worker)    |     |  or Prolog/Epilog scripts   |
+---------------------+     +-----------------------------+
          |
          |  trigger connection to quantum servers
          v
+---------------------+     +-----------------------------+
|   RabbitMQ Server   |<--->|  qdaemon                    |
|   (message broker)  |     |  (Quantum Daemon)           |
+---------------------+     +-----------------------------+
                                        |
                                        |  quantum task offloading
                                        v
                             +-------------------------------+
                             |  QPU / Simulator backends     |
                             +-------------------------------+
```

- **SLURM Controller** schedules jobs and manages QPU resources via GRES.
- **SPANK plugins** hook into `slurm_spank_job_prolog` and `slurm_spank_job_epilog` to bring
  the quantum stack up and down with each job.
- **RabbitMQ** acts as the message broker between the compute node and the quantum daemon.
- **qdaemon** (`qdaemon`) receives quantum circuits from the job and offloads them to the
  target QPU or simulator backend.

## How to Use This Documentation

- [Getting Started](getting_started.md) — prerequisites, building the plugins, and installing them on compute nodes.
- [Deployment](deployment.md) — configuring SLURM, registering plugins, and setting up the full quantum stack on a real cluster.