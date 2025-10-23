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

SPANK_PLUGIN(unload_mqss, 1);

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

void unload_rabbitmq_server(FILE *log_spank_epilog, char user_id_str[]) {
    fprintf(log_spank_epilog, "[log] Unloading RabbitMQ server...\n");

    // check username to run the loading-rabbitmq script
    char check_username_cmd[256];
    snprintf(check_username_cmd, sizeof(check_username_cmd), "id -u -n %s", user_id_str);
    fprintf(log_spank_epilog, "[log] check user name: %s\n", check_username_cmd);
    FILE *fptr_check_username_cmd = popen(check_username_cmd, "r");
    char output_check_user_cmd[128];
    fgets(output_check_user_cmd, sizeof(output_check_user_cmd), fptr_check_username_cmd);
    char username[64];
    sscanf(output_check_user_cmd, "%s", username);
    fprintf(log_spank_epilog, "[log] username: %s\n", username);

    // unload rabbitmq server
    char output_unload_rabbitmq[1024];
    char unload_rabbitmq_cmd[256];
    snprintf(unload_rabbitmq_cmd, sizeof(unload_rabbitmq_cmd), 
                "runuser -u %s -- /usr/bin/bash /home/ubuntu/shared_nfs_slurm/mqss-scripts/unload-rabbitmq.sh", username);
    fprintf(log_spank_epilog, "[log] unload rabbitmq cmd: %s\n", unload_rabbitmq_cmd);
    FILE *fptr_unload_rabbitmq = popen(unload_rabbitmq_cmd, "r");
    if (fptr_unload_rabbitmq == NULL){
       fprintf(log_spank_epilog, "\t Error: failed to unload rabbitmq-server\n");
       exit(1);
    }    
    fgets(output_unload_rabbitmq, sizeof(output_unload_rabbitmq), fptr_unload_rabbitmq);
    fprintf(log_spank_epilog, output_unload_rabbitmq);
    // slurm_error("%s", output_unload_rabbitmq);
    
    fprintf(log_spank_epilog, "[log] RabbitMQ server unloaded.\n");
}

void unload_qdaemon_server(FILE *log_spank_epilog, char user_id_str[]) {
    fprintf(log_spank_epilog, "[log] Unloading Qdaemon server...\n");

    // check username to run the loading-rabbitmq script
    char check_username_cmd[256];
    snprintf(check_username_cmd, sizeof(check_username_cmd), "id -u -n %s", user_id_str);
    FILE *fptr_check_username_cmd = popen(check_username_cmd, "r");
    char output_check_user_cmd[128];
    fgets(output_check_user_cmd, sizeof(output_check_user_cmd), fptr_check_username_cmd);
    char username[64];
    sscanf(output_check_user_cmd, "%s", username);

    // unload qdaemon server
    char output_unload_qdaemon[1024];
    char unload_qdaemon_cmd[256];
    snprintf(unload_qdaemon_cmd, sizeof(unload_qdaemon_cmd), 
                "runuser -u %s -- /usr/bin/bash /home/ubuntu/shared_nfs_slurm/mqss-scripts/unload-pyqdaemon.sh", username);
    fprintf(log_spank_epilog, "[log] unload qdaemon cmd: %s\n", unload_qdaemon_cmd);
    FILE *fptr_unload_qdaemon = popen(unload_qdaemon_cmd, "r");
    if (fptr_unload_qdaemon == NULL){
       fprintf(log_spank_epilog, "\t Error: failed to unload qdaemon-server\n");
       exit(1);
    }    
    fgets(output_unload_qdaemon, sizeof(output_unload_qdaemon), fptr_unload_qdaemon);
    fprintf(log_spank_epilog, output_unload_qdaemon);
    // slurm_error("%s", output_unload_qdaemon);
    
    fprintf(log_spank_epilog, "[log] Qdaemon server unloaded.\n");
}

int slurm_spank_job_epilog(spank_t sp, int ac, char **av)
{
    // Create and open a log file for epilog
    FILE *fptr_spank_epilog;

    // Check qpu-required jobs
    char job_id_str[32] = {0};
    char user_id_str[32] = {0};
    uint32_t job_id;
    uid_t user_id;
    spank_get_item(sp, S_JOB_ID, &job_id, sizeof(job_id));
    spank_get_item(sp, S_JOB_UID, &user_id, sizeof(user_id));

    // Run scontrol to get the job details
    char scontrol_cmd[256];
    sprintf (job_id_str, "%u", job_id);
    sprintf (user_id_str, "%u", user_id);
    snprintf(scontrol_cmd, sizeof(scontrol_cmd), "scontrol show job %s | grep gres", job_id_str);
    
    FILE *fp_scontrol_cmd = popen(scontrol_cmd, "r");
    char output_scontrol[1024];
    fgets(output_scontrol, sizeof(output_scontrol), fp_scontrol_cmd);
    pclose(fp_scontrol_cmd);

    char qpu_request[] = "qpu";
    int check_qpu = strstr(output_scontrol, qpu_request) != NULL;
    if (check_qpu) {

        // Create the log folder if it doesn't exist
        FILE *pptr_create_log_dir = popen("mkdir -p /tmp/slurm_jobs", "r");
        pclose(pptr_create_log_dir);

        // Open a file in writing mode
        fptr_spank_epilog = fopen("/tmp/slurm_jobs/spank_unload_mqss_log.txt", "w");
        fprintf(fptr_spank_epilog, "[log] Job ID: %d\n", job_id);
        fprintf(fptr_spank_epilog, "[log] User ID: %ld\n", (long int)user_id);
        fprintf(fptr_spank_epilog, "[log] scontrol: %s\n", scontrol_cmd);
        fprintf(fptr_spank_epilog, output_scontrol);

        // Start unloading mqss
        fprintf(fptr_spank_epilog, "[log] Unloading mqss on compute nodes\n");
        
        // Call to unload qdaemon server
        unload_qdaemon_server(fptr_spank_epilog, user_id_str);

        // Run the bash script to unload rabbitmq-server
        unload_rabbitmq_server(fptr_spank_epilog, user_id_str);
        
    } else {
        fprintf(fptr_spank_epilog, "[log] QPU is not required\n");
        fclose(fptr_spank_epilog);
        return 0;
    }

    // Close the log file
    fclose(fptr_spank_epilog);

    return 0;
}

static int _tmpdir_init_opts(spank_t sp, int ac, char **av)
{
    return 0;
}

