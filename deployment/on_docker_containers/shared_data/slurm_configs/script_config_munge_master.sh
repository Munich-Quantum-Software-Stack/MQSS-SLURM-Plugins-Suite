sudo cp /etc/munge/munge.key /home/admin/shared/slurm_storage/munge_key/

sudo systemctl enable munge

sudo systemctl start munge

munge -n | unmunge | grep STATUS
