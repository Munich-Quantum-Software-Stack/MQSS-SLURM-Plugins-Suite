sudo mkdir /run/slurm /var/spool/slurmd /var/log/slurm

sudo chown -R slurm:slurm /run/slurm /var/spool/slurmd /var/log/slurm

sudo chmod -R 755 /var/spool/slurmd /var/log/slurm

sudo chmod -R 770 /run/slurm

sudo touch /var/log/slurm/slurmd.log
sudo chown slurm:slurm /var/log/slurm/slurmd.log
sudo chmod 755 /var/log/slurm/slurmd.log

sudo touch /run/slurm/slurmd.pid
sudo chmod 770 /run/slurm/slurmd.pid
sudo chown slurm:slurm /run/slurm/slurmd.pid



