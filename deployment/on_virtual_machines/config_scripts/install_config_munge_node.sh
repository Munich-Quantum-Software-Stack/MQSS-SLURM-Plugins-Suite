# install the packages
sudo apt-get install libmunge-dev libmunge2 munge
    
# copy the munge key from the master node
sudo cp /home/ubuntu/shared_nfs_slurm/configs/munge.key /etc/munge/
    
# change the ownership and permission
sudo chown munge:munge /etc/munge/munge.key
sudo chmod 400 /etc/munge/munge.key
    
# enable and start the munge service
sudo systemctl enable munge
sudo systemctl start munge
    
# check munge (optional)
munge -n | unmunge | grep STATUS
