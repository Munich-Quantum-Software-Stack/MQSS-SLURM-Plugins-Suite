sudo touch /var/log/slurm/slurmd.log /run/slurm/slurmd.pid 

sudo chown slurm:slurm /var/log/slurm/slurmd.log /run/slurm/slurmd.pid

sudo chmod 770 /run/slurm/slurmd.pid
