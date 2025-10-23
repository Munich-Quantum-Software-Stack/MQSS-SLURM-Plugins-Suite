sudo rm /etc/systemd/system/multi-user.target.wants/slurmd.service
sudo rm /etc/systemd/system/multi-user.target.wants/slurmcltd.service
sudo rm /etc/systemd/system/multi-user.target.wants/slurmdbd.service

sudo cp ./unitservice_files/slurmd.service /etc/systemd/system/
sudo cp ./unitservice_files/slurmctld.service /etc/systemd/system/
sudo cp ./unitservice_files/slurmdbd.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable slurmdbd
sudo systemctl enable slurmctld
