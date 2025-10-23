sudo mkdir -p /run/slurm /var/spool/slurmd /var/spool/slurmctld /var/log/slurm

sudo chown -R slurm:slurm /run/slurm /var/spool/slurmd /var/spool/slurmctld /var/log/slurm

sudo chmod -R 755 /var/spool/slurmd /var/spool/slurmctld /var/log/slurm
