#!/bin/sh
#SBATCH -J ghz_qexa20
#SBATCH -p wolpy
#SBATCH -o ./%x_%j.out
#SBATCH -e ./%x_%j.err
#SBATCH --ntasks=1

## --------------------------------------------------
/bin/sh /home/sw/qis/wolpy/mqss/scripts/load-mqss.sh
## --------------------------------------------------

## --------------------------------------------------
module use -p /home/sw/qis/wolpy/hpcqc-software/modules/linux-rocky9-icelake/
module load python/3.11.7-gcc-11.4.1-o75q74w
module load py-qiskit
module load py-hpc-offload-provider
## --------------------------------------------------

## --------------------------------------------------
python ghz_circuit.py
## --------------------------------------------------

## --------------------------------------------------
/bin/sh /home/sw/qis/wolpy/mqss/scripts/unload-mqss.sh
## --------------------------------------------------

#!/bin/sh
#SBATCH -J qpi_bellstate
#SBATCH -p wolpy
#SBATCH -o ./%x_%j.out
#SBATCH -e ./%x_%j.err
#SBATCH --ntasks=1

## ---------------------------------------------------
/bin/sh /home/sw/qis/wolpy/mqss/scripts/load-mqss.sh
## ---------------------------------------------------

## ---------------------------------------------------
module use -p /home/sw/qis/wolpy/hpcqc-software/modules/linux-rocky9-icelake/
module load quantum-programming-interface
## ---------------------------------------------------

## ---------------------------------------------------
./build/qpi_bellstates
## ---------------------------------------------------

## ---------------------------------------------------
/bin/sh /home/sw/qis/wolpy/mqss/scripts/unload-mqss.sh
## --------------------------------------------------

