#!/bin/sh
#SBATCH -J example2
#SBATCH -o ./%x_%j.out
#SBATCH -e ./%x_%j.err
#SBATCH --ntasks=1
#SBATCH --gres=qpu:1
#SBATCH --cpus-per-task=1
#SBATCH --partition=testbed
#SBATCH --time=00:00:05

echo -e 'Submitted a sample job with qpu requirement ...'
echo -e 'Checking the hostname, where the job is allocated and run: '
hostname

./example2
