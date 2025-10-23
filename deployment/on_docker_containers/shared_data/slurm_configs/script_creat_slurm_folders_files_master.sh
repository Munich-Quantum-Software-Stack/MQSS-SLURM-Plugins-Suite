sudo mkdir /run/slurm /var/spool/slurmd /var/spool/slurmctld /var/log/slurm

sudo chown -R slurm:slurm /run/slurm /var/spool/slurmd /var/spool/slurmctld /var/log/slurm

sudo chmod -R 755 /var/spool/slurmctld /var/spool/slurmd /var/log/slurm

sudo touch /var/log/slurm/slurmctld.log /var/log/slurm/slurm_jobacct.log /var/log/slurm/slurm_jobcomp.log

