INSTALL_PATH=/home/ubuntu/shared_nfs_slurm/spank_plugins/shared_plugins/

all: load_unload_rabbitmq.so

load_unload_rabbitmq.so: load_unload_rabbitmq.c
	gcc -I/usr/local/include/slurm -std=gnu99 -Wall -o load_unload_rabbitmq.o -fPIC -c load_unload_rabbitmq.c
	gcc -shared -o load_unload_rabbitmq.so load_unload_rabbitmq.o

clean:
	rm -f load_unload_rabbitmq.o load_unload_rabbitmq.so

install: load_unload_rabbitmq.so
	cp load_unload_rabbitmq.so ${INSTALL_PATH}
