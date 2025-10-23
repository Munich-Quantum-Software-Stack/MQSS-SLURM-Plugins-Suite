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

SPANK_PLUGIN(load_mqss, 1);

#define MAX_BIND_DIRS 16

static int _tmpdir_init_opts(spank_t sp, int ac, char **av);

/*
 *  Called from both srun and slurmd
 */
int slurm_spank_init(spank_t sp, int ac, char **av)
{
	if (spank_context() != S_CTX_REMOTE)
        return (0);

	return _tmpdir_init_opts(sp, ac, av);
}

void load_rabbitmq_server(FILE *log_spank_prolog, char user_id_str[]) {
    fprintf(log_spank_prolog, "[log] Loading RabbitMQ server...\n");

    // check username to run the loading-rabbitmq script
    char check_username_cmd[256];
    snprintf(check_username_cmd, sizeof(check_username_cmd), "id -u -n %s", user_id_str);
    fprintf(log_spank_prolog, "[log] check user name: %s\n", check_username_cmd);
    FILE *fptr_check_username_cmd = popen(check_username_cmd, "r");
    char output_check_user_cmd[128];
    fgets(output_check_user_cmd, sizeof(output_check_user_cmd), fptr_check_username_cmd);
    char username[64];
    sscanf(output_check_user_cmd, "%s", username);
    fprintf(log_spank_prolog, "[log] username: %s\n", username);

    // load rabbitmq server
    char output_load_rabbitmq[1024];
    char load_rabbitmq_cmd[256];
    snprintf(load_rabbitmq_cmd, sizeof(load_rabbitmq_cmd), 
                "runuser -u %s -- /usr/bin/bash /home/ubuntu/shared_nfs_slurm/mqss-scripts/load-rabbitmq.sh", username);
    fprintf(log_spank_prolog, "[log] load rabbitmq cmd: %s\n", load_rabbitmq_cmd);
    FILE *fptr_load_rabbitmq = popen(load_rabbitmq_cmd, "r");
    if (fptr_load_rabbitmq == NULL){
       fprintf(log_spank_prolog, "\t Error: failed to load rabbitmq-server\n");
       exit(1);
    }    
    fgets(output_load_rabbitmq, sizeof(output_load_rabbitmq), fptr_load_rabbitmq);
    fprintf(log_spank_prolog, output_load_rabbitmq);
    // slurm_error("%s", output_load_rabbitmq);
    
    fprintf(log_spank_prolog, "[log] RabbitMQ server loaded successfully.\n");
}

void load_qdaemon_server(FILE *log_spank_prolog, char user_id_str[]) {
    fprintf(log_spank_prolog, "[log] Loading MQSS-Qdaemon server...\n");

    // check username to run the loading-rabbitmq script
    char check_username_cmd[256];
    snprintf(check_username_cmd, sizeof(check_username_cmd), "id -u -n %s", user_id_str);
    FILE *fptr_check_username_cmd = popen(check_username_cmd, "r");
    char output_check_user_cmd[128];
    fgets(output_check_user_cmd, sizeof(output_check_user_cmd), fptr_check_username_cmd);
    char username[64];
    sscanf(output_check_user_cmd, "%s", username);

    // load qdaemon server
    char output_load_qdaemon[1024];
    char load_qdaemon_cmd[256];

    // try again opening a screen session
    snprintf(load_qdaemon_cmd, sizeof(load_qdaemon_cmd), 
                "runuser -u %s -- /usr/bin/screen -S screen_pydaemon_%s -d -m /usr/bin/bash /home/ubuntu/shared_nfs_slurm/mqss-scripts/load-pyqdaemon.sh &", username, username);
    fprintf(log_spank_prolog, "[log] load qdaemon cmd: %s\n", load_qdaemon_cmd);

    FILE *pptr_load_qdaemon = popen(load_qdaemon_cmd, "r");
    if (pptr_load_qdaemon == NULL){
       fprintf(log_spank_prolog, "\t Error: failed to load mqss-qdaemon-server\n");
       exit(1);
    }    
    fgets(output_load_qdaemon, sizeof(output_load_qdaemon), pptr_load_qdaemon);
    fprintf(log_spank_prolog, output_load_qdaemon);
    // slurm_error("%s", output_load_qdaemon);
    sleep(1);
    
    fprintf(log_spank_prolog, "[log] MQSS-Qdaemon server loaded successfully.\n");
}

int slurm_spank_job_prolog(spank_t sp, int ac, char **av)
{
    // Create and open a log file for prolog
    FILE *fptr_spank_prolog;

    // Check qpu-required jobs
    char job_id_str[32] = {0};
    char user_id_str[32] = {0};
    uint32_t job_id;
    uid_t user_id;
    spank_get_item(sp, S_JOB_ID, &job_id, sizeof(job_id));
    spank_get_item(sp, S_JOB_UID, &user_id, sizeof(user_id));

    // Scontrol to get the job details
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

        // Write logs
        fptr_spank_prolog = fopen("/tmp/slurm_jobs/spank_load_mqss_log.txt", "w");
        fprintf(fptr_spank_prolog, "[log] Check job requirement... \n");
        fprintf(fptr_spank_prolog, "[log] Job ID: %d\n", job_id);
        fprintf(fptr_spank_prolog, "[log] User ID: %ld\n", (long int)user_id);
        fprintf(fptr_spank_prolog, "[log] scontrol: %s\n", scontrol_cmd);
        fprintf(fptr_spank_prolog, output_scontrol);

        // Start loading mqss
        fprintf(fptr_spank_prolog, "[log] Start loading mqss on compute nodes \n");
        // Run the bash script to load rabbitmq-server
        load_rabbitmq_server(fptr_spank_prolog, user_id_str);
        // Run the bash script to load qdaemon
        load_qdaemon_server(fptr_spank_prolog, user_id_str);

    } else {
        fprintf(fptr_spank_prolog, "[log] QPU is not required\n");
        fclose(fptr_spank_prolog);
        return 0;
    }

    // Close the log file
    fclose(fptr_spank_prolog);
    return 0;
}

static int _tmpdir_init_opts(spank_t sp, int ac, char **av)
{
    return 0;
}

