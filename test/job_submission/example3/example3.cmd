#!/bin/sh
#SBATCH -J example3
#SBATCH -o ./%x_%j.out
#SBATCH -e ./%x_%j.err
#SBATCH --ntasks=1
#SBATCH --gres=qpu:1
#SBATCH --cpus-per-task=1
#SBATCH --partition=testbed
#SBATCH --time=00:00:45

echo '-----------------------------------------------'
echo 'Submitted a sample job with qpu requirement ...'
echo 'Checking the hostname, where the job is allocated and run: '
hostname
echo '-----------------------------------------------'
echo ''

echo '-----------------------------------------------'
echo 'Loading the spack env, e.g., qiskit, hpc-offloader'
. /home/ubuntu/spack/share/spack/setup-env.sh
spack env activate mqss
spack load py-hpc-offload-provider 
spack load py-qiskit 
echo '-----------------------------------------------'
echo ''

# Run the quantum task from users
echo '-----------------------------------------------'
echo 'Run the user quantum application'
python3.11 ./hpc-provider-ex.py 
echo '-----------------------------------------------'
echo ''

