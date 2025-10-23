#!/bin/sh
#SBATCH -J example1
#SBATCH -o ./%x_%j.out
#SBATCH -e ./%x_%j.err
#SBATCH --ntasks=1
##SBATCH --gres=qpu:1
#SBATCH --cpus-per-task=1
#SBATCH --partition=testbed
#SBATCH --time=00:00:05

echo -e 'Submitted a sample job to test slurm cluster on docker containers ...'
echo -e 'Checking the hostname: '
hostname

./example1
