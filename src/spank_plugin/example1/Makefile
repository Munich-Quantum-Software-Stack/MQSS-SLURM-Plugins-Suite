INSTALL_PATH=/home/ubuntu/shared_nfs_slurm/spank_plugins/shared_plugins/

all: example1.so

example1.so: example1.c
	gcc -I/usr/local/include/slurm -std=gnu99 -Wall -o example1.o -fPIC -c example1.c
	gcc -shared -o example1.so example1.o

clean:
	rm -f example1.o example1.so

install: example1.so
	cp example1.so ${INSTALL_PATH}

