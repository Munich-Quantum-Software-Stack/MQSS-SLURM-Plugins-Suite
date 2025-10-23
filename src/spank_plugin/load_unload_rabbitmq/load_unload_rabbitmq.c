#define _GNU_SOURCE

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <linux/limits.h>
#include <sys/mount.h>
#include <slurm/spank.h>
#include <unistd.h>
#include <sched.h>

SPANK_PLUGIN(load_unload_rabbitmq, 1);

#define MAX_BIND_DIRS 16


static int _tmpdir_init_opts(spank_t sp, int ac, char **av);

/*
 *  Called from both srun and slurmd
 */
int slurm_spank_init(spank_t sp, int ac, char **av)
{
	if (spank_context () != S_CTX_REMOTE)
        return (0);

	return _tmpdir_init_opts(sp, ac, av);
}

int slurm_spank_job_prolog(spank_t sp, int ac, char **av)
{
    FILE *fptr_spank_prolog;

    // Open a file in writing mode
    fptr_spank_prolog = fopen("/tmp/slurm_jobs/spank_log.txt", "w");

    // Write some text to the file
    fprintf(fptr_spank_prolog, "-------------------------------\n");
    fprintf(fptr_spank_prolog, "Start rabbitmq-server on compute nodes \n");
    fprintf(fptr_spank_prolog, "-------------------------------\n");

    fprintf(fptr_spank_prolog, "...\n");


    // load the bash script to load rabbitmq-server
    FILE *fp_load_rabbitmq;
    char log_rabbitmq[1024];
    fp_load_rabbitmq = popen("runuser -u ubuntu -- /usr/bin/bash /home/ubuntu/shared_nfs_slurm/mqss-scripts/load-rabbitmq.sh", "r");
    if (fp_load_rabbitmq == NULL){
       fprintf(fptr_spank_prolog, "\t Error: failed to run the command \n");
       exit(1);
    }    
    fgets(log_rabbitmq, sizeof(log_rabbitmq), fp_load_rabbitmq);
    // fprintf(fptr_spank_prolog, log_rabbitmq);
    // slurm_error("%s", log_rabbitmq);
    pclose(fp_load_rabbitmq);

    fprintf(fptr_spank_prolog, "-------------------------------\n");
    fprintf(fptr_spank_prolog, "Passed source load rabbitmq script \n");
    fprintf(fptr_spank_prolog, "-------------------------------\n");

    // load the bash script to load pyqdaemon
    FILE *fp_load_pyqdaemon;
    char log_pyqdaemon[1024];
    // fp_load_pyqdaemon = popen("runuser -u ubuntu -- py_qdaemon --config-file /home/ubuntu/spack/opt/spack/linux-ubuntu22.04-icelake/gcc-11.4.0/py-hpcqc-qdaemon-0.3.5-th7lt5cjwaep4qyeeat62kuytqbpmznt/lib/python3.11/site-packages/hpcqc/config/qd-config.json &", "r");
    fp_load_pyqdaemon = popen("runuser -u ubuntu -- /usr/bin/bash /home/ubuntu/shared_nfs_slurm/mqss-scripts/load-pyqdaemon.sh", "r");
    if (fp_load_pyqdaemon == NULL){
       fprintf(fptr_spank_prolog, "\t Error: failed to run pyqdaemon \n");
       exit(1);
    }
    fgets(log_pyqdaemon, sizeof(log_pyqdaemon), fp_load_pyqdaemon);
    pclose(fp_load_pyqdaemon);

    // system("runuser -u ubuntu -- . /home/ubuntu/shared_nfs_slurm/mqss-scripts/load-pyqdaemon.sh");
    // system("runuser -u ubuntu -- py_qdaemon --config-file /home/ubuntu/spack/opt/spack/linux-ubuntu22.04-icelake/gcc-11.4.0/py-hpcqc-qdaemon-0.3.5-th7lt5cjwaep4qyeeat62kuytqbpmznt/lib/python3.11/site-packages/hpcqc/config/qd-config.json &")
    
    // Close the log file
    fclose(fptr_spank_prolog);

    return 0;
}

static int _tmpdir_init_opts(spank_t sp, int ac, char **av)
{
    return 0;
}

