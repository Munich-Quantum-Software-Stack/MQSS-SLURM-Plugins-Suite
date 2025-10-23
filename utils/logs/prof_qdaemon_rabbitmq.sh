#!/bin/bash

echo "------------------------------------" >  ./log_mmpercpu.txt
echo "Profling CPU, MEM, RUNTIME:"	    >> ./log_mmpercpu.txt
echo "------------------------------------" >> ./log_mmpercpu.txt

counter=1
while [ $counter -le 300 ]
do
	echo "Timestep ${counter}: $(date)" >> ./log_mmpercpu.txt
	sleep 1
	
	# track the information
	ps -C beam.smp,py_qdaemon -o pid,user:20,%cpu,%mem,comm >> ./log_mmpercpu.txt
	echo "" >> ./log_mmpercpu.txt

	# increase the counter
	((counter++))
done

echo "Stopped profiling!"
