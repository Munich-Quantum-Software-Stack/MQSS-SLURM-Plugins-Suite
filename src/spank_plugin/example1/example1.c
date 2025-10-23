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

SPANK_PLUGIN(example1, 1);

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
	FILE *fptr_prolog;

    // Open a file in writing mode
    fptr_prolog = fopen("/tmp/slurm_jobs/test_job_prolog.txt", "w");

    // Write some text to the file
    fprintf(fptr_prolog, "Try to write a file in /tmp/slurm_jobs for slurm_spank_job_prolog");

    // Close the file
    fclose(fptr_prolog);

    return 0;
}

static int _tmpdir_init_opts(spank_t sp, int ac, char **av)
{
    FILE *fptr;

    // Open a file in writing mode
    fptr = fopen("/tmp/slurm_jobs/test_spank_tmpdir_init.txt", "w");

    // Write some text to the file
    fprintf(fptr, "Try to write a file in /tmp/slurm_jobs for _tmpdir_init_opts");

    // Close the file
    fclose(fptr);

    return 0;
}

