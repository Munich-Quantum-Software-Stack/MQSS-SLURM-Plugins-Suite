docker run --name slurmnode1 \
    --hostname slurmnode1 \
    --privileged --tmpfs /tmp --tmpfs /run \
    --mount type=bind,source=/home/ubuntu/slurm_qpu_plugin/slurm_docker_cluster/shared_data,target=/home/admin/shared \
    -it slurm_testbed_img:1.2
    
# -it slurm_testbed_node_img:1.0 

# --cpuset-cpus="4-7" --memory="4g" \
# -v /sys/fs/cgroup:/sys/fs/cgroup:ro