docker run --name slurmmaster \
    --hostname slurmmaster \
    --privileged --tmpfs /tmp --tmpfs /run \
    --mount type=bind,source=/home/ubuntu/slurm_qpu_plugin/slurm_docker_cluster/shared_data,target=/home/admin/shared \
    -it slurm_testbed_img:1.2

# -it slurm_testbed_master_img:1.0 

# -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
# --cpuset-cpus="0-3" --memory="4g" \
# --privileged --tmpfs /tmp --tmpfs /run \