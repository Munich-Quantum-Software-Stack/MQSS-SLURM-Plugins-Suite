FROM ubuntu:22.04
# FROM ubuntu:18.04

RUN apt-get update -y

RUN apt-get install vim build-essential ufw git wget iproute2 net-tools iputils-ping openssh-server openssh-client systemd systemd-sysv dbus dbus-user-session bash-completion zsh curl libdbus-1-dev linux-headers-generic -y

RUN apt-get install sudo -y

RUN apt-get install python3 python3-pip openmpi-bin openmpi-common libopenmpi-dev hwloc -y

RUN useradd -m admin && echo "admin:admin" | chpasswd && adduser admin sudo && echo "admin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers 

RUN su admin && mkdir /home/admin/shared

# Add users for munge and slurm
RUN adduser -u 1001 munge --disabled-password --gecos ""
RUN adduser -u 1002 slurm --disabled-password --gecos ""

# Install packages related to slurm
RUN apt install libmunge-dev libmunge2 munge mariadb-server mariadb-client -y

EXPOSE 6817 6818 6819 3306 22

USER admin
WORKDIR /home/admin

ENTRYPOINT ["/sbin/init"]

