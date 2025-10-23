# install the packages
sudo apt-get install libmunge-dev libmunge2 munge

# enable and start the munge service
sudo systemctl enable munge
sudo systemctl start munge
    
# test munge (optional)
munge -n | unmunge | grep STATUS
    
# copy the munge key to the shared folder to let the compute nodes can copy the key
sudo cp /etc/munge/munge.key /home/ubuntu/shared_nfs_slurm/configs

sudo chown munge:munge /home/ubuntu/shared_nfs_slurm/configs/munge.key

# for enabling copy the key to somewhere at the node side
sudo chmod 644 /home/ubuntu/shared_nfs_slurm/configs/munge.key

