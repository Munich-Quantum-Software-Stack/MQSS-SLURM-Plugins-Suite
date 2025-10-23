sudo cp /home/admin/shared/slurm_storage/munge_key/munge.key /etc/munge/

sudo chown munge:munge /etc/munge/munge.key

sudo chmod 400 /etc/munge/munge.key

sudo systemctl enable munge

sudo systemctl start munge

munge -n | unmunge | grep STATUS
