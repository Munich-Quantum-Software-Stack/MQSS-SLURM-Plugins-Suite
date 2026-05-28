INSTALL_PATH=/home/ubuntu/shared_nfs_slurm/spank_plugins/shared_plugins/

all: example.so

example.so: example.c
	gcc -I/usr/local/include/slurm -std=gnu99 -Wall -o example.o -fPIC -c example.c
	gcc -shared -o example.so example.o

clean:
	rm -f example.o example.so

install: example.so
	cp example.so ${INSTALL_PATH}

