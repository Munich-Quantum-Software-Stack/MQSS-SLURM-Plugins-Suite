# MQSS SLURM Plugins Suite

A example suite of SLURM plugins for integrating Quantum Processing Units (QPUs) into HPC workloads. Quantum resources are exposed to SLURM as co-processors (or can be considered as accelerators like GPUs), allowing standard job scripts to request and use QPU time. Plugins can be implemented via two SLURM extension mechanisms — **SPANK** or **Prolog/Epilog** — so they plug in and out without modifying the SLURM source code.

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
|                     |     |                             |
+---------------------+     +-----------------------------+
          |   |
          |   | (trigger connection to Quantum Servers)
          v   v
+---------------------+     +-----------------------------+
|   RabbitMQ Server   |<--->|   qdaemon                   |
|   (message broker)  |     |  (Quantum Daemon)           |
+---------------------+     +-----------------------------+
                                        |
                                        |  (Quantum Tasks offloading)
                                        v
                             +--------------------------------------+
                             |  real QPU/Simulator device backends  |
                             +--------------------------------------+
```

- **SLURM Controller** dispatches jobs to compute nodes and manages QPU resources via GRES.
- **SPANK plugins** run automatically at the phases of job prolog/epilog steps on compute nodes, starting and stopping connection to the quantum servers.
- **qdaemon** enables receiving quantum circuits and offloads them to the target QPU or simulator backends.

## Requirements

- SLURM 23.11 (built from source or via package)
- GCC with C99 support (`-std=gnu99`)
- SLURM development headers (`libslurm-dev` on Ubuntu, or built from the SLURM source tree)
- Python 3.10+ with `py_qdaemon` and dependencies installed (for the quantum daemon)
- RabbitMQ server

## Repository Structure

```
.
├── src/
│   ├── spank_plugin/           # SPANK plugins (compiled to .so)
│   │   ├── load_unload_rabbitmq/   # Start/stop communication brokers at job boundaries
│   │   ├── load_unload_mqss/       # Start/stop communication of quantum daemon
│   │   └── example/                # Minimal SPANK plugin example
│   └── prep_plugin/            # Prolog/Epilog shell scripts (alternative for testing connection with quantum servers)
│       ├── prolog_scripts/         # Run before job starts
│       └── epilog_scripts/         # Run after job ends
├── mqss_scripts/               # Helper scripts to load/unload MQSS components
├── deployment/                 # Setup instructions and config files
│   ├── on_virtual_machines/        # VM-based testbed (Ubuntu 22.04, NFS shared dir)
│   ├── on_docker_containers/       # Docker Compose environment for local dev
│   └── slurm/                      # SLURM build scripts (slurm-23.11)
├── test/                       # Job submission examples and quantum benchmark scripts
└── utils/                      # Utilities (string_preprocess helper, Docker Compose)
```

## Building

### SPANK plugins

Each plugin example has its own `Makefile`. With `libslurm-dev` installed, we can compile the example by simply using `make`.


The resulting `.so` files must be copied to the shared plugin directory on each compute node (default path in the Makefiles: `/home/ubuntu/shared_nfs_slurm/spank_plugins/shared_plugins/`):

```bash
make install
```

Then register the plugin in `/etc/slurm/plugstack.conf` on each node:

```
required /path/to/shared_plugins/load_unload_rabbitmq.so
```

Instead of using SPANK to trigger the connection to the side of quantum servers, we can Prolog/Epilog scripts.

## Deployment

Detailed setup guides are in `deployment/`:

| Environment | Guide |
|-------------|-------|
| Virtual machines (Ubuntu 22.04, NFS) | [`deployment/on_virtual_machines/`](deployment/on_virtual_machines/) |
| Docker containers (local dev) | [`deployment/on_docker_containers/`](deployment/on_docker_containers/) |
| SLURM build from source (slurm-23.11) | [`deployment/slurm/`](deployment/slurm/) |

A testbed uses two nodes — `slurm_master` (controller) and `slurm_worker` (compute) — connected via NFS at `/home/ubuntu/shared_nfs_slurm`. Jobs are submitted from `slurm_master`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## License

This project is released under the Apache License v2.0 with LLVM Exceptions. See [LICENSE](LICENSE) for more information. Any contribution to the project is assumed to be under the same license.
