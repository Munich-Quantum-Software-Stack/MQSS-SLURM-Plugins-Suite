# Getting Started

\tableofcontents

## Requirements

**System (Debian/Ubuntu 22.04):**

```bash
sudo apt update
sudo apt install -y build-essential libslurm-dev
```

`libslurm-dev` provides the `<slurm/spank.h>` header required to compile SPANK plugins.
If building SLURM from source (see [`deployment/slurm/`](../deployment/slurm/)), point the
compiler at the source tree headers instead:

```bash
# example when SLURM is built from source under /usr/local
gcc -I/usr/local/include/slurm ...
```

**Runtime (on every compute node):**

| Component | Purpose |
|---|---|
| SLURM 23.11 | Workload manager (controller + daemon) |
| RabbitMQ server | Message broker for quantum task offloading |
| Python 3.10+ | Required by `qdaemon` |
| `qdaemon` | Quantum daemon that offloads circuits to QPU/simulator |
| NFS shared directory | Used to distribute plugins and scripts across nodes |

## Building the SPANK Plugins

Each plugin has its own `Makefile`.

Each `make` invocation produces a `.so` shared library alongside the source file.

The default include path in the Makefiles is `-I/usr/local/include/slurm`.
If your SLURM headers are elsewhere (e.g., `/usr/include/slurm` from `libslurm-dev`),
GCC finds them automatically via the default system include path, so no change is needed
for a standard `apt`-based install.

## Installing the Plugins

The `.so` files must be placed on a path that is accessible to `slurmd` on every compute node.
Using a shared NFS directory is the simplest approach:

```bash
# from each plugin directory, after make:
make install
```

As an example, the default install path in the Makefiles is:

```
/home/ubuntu/shared_nfs_slurm/spank_plugins/shared_plugins/
```

Adjust `INSTALL_PATH` in the relevant `Makefile` to match your NFS mount point before running
`make install`.

## Building the Utility

```bash
cd utils && make
```

This produces the `string_preprocess` binary used by some helper scripts.