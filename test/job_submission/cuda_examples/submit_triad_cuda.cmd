#!/bin/sh
#SBATCH -J triad_cuda
#SBATCH -o ./%x_%j.out
#SBATCH -e ./%x_%j.err
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=1
#SBATCH --partition=wolpy_gpu
#SBATCH --time=00:02:00

echo -e '----------------------------------------'
echo -e ' Load nvhpc environment'
echo -e '----------------------------------------'
module load /home/di35hef/nvhpc/modulefiles/nvhpc/25.5

echo -e '----------------------------------------'
echo -e ' Submitting job on wolpy_gpu partition'
echo -e '----------------------------------------'
echo -e ' + Allocated on: '
hostname

nsys profile -t cuda --stats=true ./triad_cuda
