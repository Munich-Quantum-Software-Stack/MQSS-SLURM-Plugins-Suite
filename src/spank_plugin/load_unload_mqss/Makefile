INSTALL_PATH=/home/ubuntu/shared_nfs_slurm/spank_plugins/shared_plugins/

all: load_unload_mqss load_mqss unload_mqss

load_mqss: load_mqss.c
	gcc -I/usr/local/include/slurm -std=gnu99 -Wall -o load_mqss.o -fPIC -c load_mqss.c
	gcc -shared -o load_mqss.so load_mqss.o

unload_mqss: unload_mqss.c
	gcc -I/usr/local/include/slurm -std=gnu99 -Wall -o unload_mqss.o -fPIC -c unload_mqss.c
	gcc -shared -o unload_mqss.so unload_mqss.o

load_unload_mqss: load_unload_mqss.c
	gcc -I/usr/local/include/slurm -std=gnu99 -Wall -o load_unload_mqss.o -fPIC -c load_unload_mqss.c
	gcc -shared -o load_unload_mqss.so load_unload_mqss.o

clean:
	rm -f load_unload_mqss.o load_unload_mqss.so load_mqss.o load_mqss.so unload_mqss.o unload_mqss.so

install: load_unload_mqss.so load_mqss.so unload_mqss.so
	cp load_unload_mqss.so load_mqss.so unload_mqss.so ${INSTALL_PATH}
