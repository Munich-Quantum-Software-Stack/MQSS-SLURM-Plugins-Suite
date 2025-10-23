import numpy as np
import pandas as pd
import re
import matplotlib.pyplot as plt

def read_prof_log(filename):

    # vars for storing profiled data
    timestamp_arr = []

    # open file
    file_data1 = open(filename, 'r')

    count_line = 0 
    for line in file_data1:
        count_line += 1
        line_data = line.strip().split(" ")
        if "Timestep" in line_data:
            # print("Line {}: {}".format(count_line, line_data))
            count = int(re.findall(r'\d+', line_data[1])[0])
            date  = line_data[2] + " " + line_data[3] + " " + line_data[4]
            time  = line_data[5]
            # print("Extracted: {} {} {}".format(count, date, time))

            # append time stamp
            timestamp_arr.append(count)

    # close file
    file_data1.close()

    # convert timestamp_arr to np array
    timestamp_nparr = np.array(timestamp_arr)

    # size of the time stamps or num. samples
    num_prof_samples = len(timestamp_nparr)

    # create the arrays that store the profiled values of rabbitmq and qdaemon
    global rabbitmq_beam_pids 
    rabbitmq_beam_pids = [0, 0, 0]
    rabbitmq_beam1_cpu = np.zeros(num_prof_samples)
    rabbitmq_beam2_cpu = np.zeros(num_prof_samples)
    rabbitmq_beam3_cpu = np.zeros(num_prof_samples)
    rabbitmq_beam1_mem = np.zeros(num_prof_samples)
    rabbitmq_beam2_mem = np.zeros(num_prof_samples)
    rabbitmq_beam3_mem = np.zeros(num_prof_samples)
    qdaemon_pid = 0
    qdaemon_cpu = np.zeros(num_prof_samples)
    qdaemon_mem = np.zeros(num_prof_samples)

    # read the log file again and extract cpu mem values
    file_data2 = open(filename, 'r')
    prev_time_idx  = 0
    for line in file_data2:
        line_data = line.strip().split(" ")
        # print(line_data)
        
        time_idx = prev_time_idx
        if "Timestep" in line_data:
            time_idx = int(re.findall(r'\d+', line_data[1])[0])

        # check and update previous time idx
        # print("Timestep {}: cur {} - prev {}".format(time_idx, time_idx, prev_time_idx))
        prev_time_idx = time_idx
        
        if "beam.smp" in line_data:
            prof_rmq_data = [i for i in line_data if i != '']
            pid  = int(prof_rmq_data[0])
            user = prof_rmq_data[1]
            percen_cpu = float(prof_rmq_data[2])
            percen_mem = float(prof_rmq_data[3])
            proc_name  = prof_rmq_data[4]
            # print("Time index {} - {}".format(time_idx, prof_rmq_data))
            # print("PID: {}".format(pid))
            
            if rabbitmq_beam_pids[0] == 0:
                # print("First PID RabbitMQ: {} | Origin PID: {}".format(pid, rabbitmq_beam_pids[0]))
                rabbitmq_beam_pids[0] = pid
            
            if rabbitmq_beam_pids[1] == 0 and pid != rabbitmq_beam_pids[0]:
                # print("Second PID RabbitMQ: {} | Origin PID: {}".format(pid, rabbitmq_beam_pids[1]))
                rabbitmq_beam_pids[1] = pid

            print("rabbitmq_beam_pids[2] = {}".format(rabbitmq_beam_pids[2]))
            if rabbitmq_beam_pids[2] == 0 and pid != rabbitmq_beam_pids[1] and pid != rabbitmq_beam_pids[0]:
                print("Third PID RabbitMQ: {} | Origin PID: {}".format(pid, rabbitmq_beam_pids[2]))
                rabbitmq_beam_pids[2] = pid
            
            if pid == rabbitmq_beam_pids[0]:
                rabbitmq_beam1_cpu[time_idx] = percen_cpu
                rabbitmq_beam1_mem[time_idx] = percen_mem
            
            if pid == rabbitmq_beam_pids[1]:
                rabbitmq_beam2_cpu[time_idx] = percen_cpu
                rabbitmq_beam2_mem[time_idx] = percen_mem

            if pid == rabbitmq_beam_pids[2]:
                rabbitmq_beam3_cpu[time_idx] = percen_cpu
                rabbitmq_beam3_mem[time_idx] = percen_mem

        if "py_qdaemon" in line_data:
            prof_qd_data = [i for i in line_data if i != '']
            pid  = int(prof_qd_data[0])
            user = prof_qd_data[1]
            percen_cpu = float(prof_qd_data[2])
            percen_mem = float(prof_qd_data[3])
            proc_name  = prof_qd_data[4]
            if qdaemon_pid == 0:
                # print("PID Qdaemon: {} | Origin PID: {}".format(pid, qdaemon_pid))
                qdaemon_pid = pid
            if pid == qdaemon_pid:
                qdaemon_cpu[time_idx] = percen_cpu
                qdaemon_mem[time_idx] = percen_mem
    
    # convert to np arrays
    rabbitmq_beam1_cpu_nparr = np.array(rabbitmq_beam1_cpu)
    rabbitmq_beam1_mem_nparr = np.array(rabbitmq_beam1_mem)
    rabbitmq_beam2_cpu_nparr = np.array(rabbitmq_beam2_cpu)
    rabbitmq_beam2_mem_nparr = np.array(rabbitmq_beam2_mem)
    rabbitmq_beam3_cpu_nparr = np.array(rabbitmq_beam3_cpu)
    rabbitmq_beam3_mem_nparr = np.array(rabbitmq_beam3_mem)

    qdaemon_cpu_nparr = np.array(qdaemon_cpu)
    qdaemon_mem_nparr = np.array(qdaemon_mem)

    # check the array values
    # print("RabbitMQ P1-{} %CPU: {}".format(rabbitmq_beam_pids[0], rabbitmq_beam1_cpu_nparr))
    # print("RabbitMQ P1-{} %MEM: {}".format(rabbitmq_beam_pids[0], rabbitmq_beam1_mem_nparr))
    # print("")
    # print("RabbitMQ P2-{} %CPU: {}".format(rabbitmq_beam_pids[1], rabbitmq_beam2_cpu_nparr))
    # print("RabbitMQ P2-{} %MEM: {}".format(rabbitmq_beam_pids[1], rabbitmq_beam2_mem_nparr))
    # print("")
    # print("RabbitMQ P3-{} %CPU: {}".format(rabbitmq_beam_pids[2], rabbitmq_beam3_cpu_nparr))
    # print("RabbitMQ P3-{} %MEM: {}".format(rabbitmq_beam_pids[2], rabbitmq_beam3_mem_nparr))
    # print("")
    # print("Qdaemon {} %CPU: {}".format(qdaemon_pid, qdaemon_cpu_nparr))
    # print("Qdaemon {} %MEM: {}".format(qdaemon_pid, qdaemon_mem_nparr))

    # create pandas dataframe
    list_of_tuples = list(zip(timestamp_arr, rabbitmq_beam1_cpu_nparr, rabbitmq_beam2_cpu_nparr, rabbitmq_beam3_cpu_nparr, qdaemon_cpu_nparr,
                              rabbitmq_beam1_mem_nparr, rabbitmq_beam2_mem_nparr, rabbitmq_beam3_mem_nparr, qdaemon_mem_nparr))
    df = pd.DataFrame(list_of_tuples, columns=['Timestamp', 'CPU_RMQ_P1', 'CPU_RMQ_P2', 'CPU_RMQ_P3', 'CPU_QD',
                                        'MEM_RMQ_P1', 'MEM_RMQ_P2', 'MEM_RMQ_P3', 'MEM_QD'])
    return df

def plot_prof_data(data_frame, figure_name):

    x = np.arange(len(data_frame['Timestamp']))

    plt.bar(x, data_frame['CPU_RMQ_P1'],  label='CPU_RMQ_PID1')
    plt.bar(x, data_frame['CPU_RMQ_P2'],  label='CPU_RMQ_PID2')
    plt.bar(x, data_frame['CPU_RMQ_P3'],  label='CPU_RMQ_PID3') 
    plt.bar(x, data_frame['CPU_QD'],  label='CPU_QD') 

    plt.yscale("log")
    plt.legend(loc='upper right')
    plt.xlabel("Timestamp (s - directing to runtime)")
    plt.ylabel("%CPU")
    plt.title('CPU Percentage of RabbitMQ and Qdaemon')
    plt.savefig(figure_name, bbox_inches='tight')
    # plt.show()
        
# submit ghz circuit via slurm sbatch
file_rmq_qd_job_run1 = './log_memcpu_rabbitmq_qdaemon_run1.txt'
file_rmq_qd_job_run2 = './log_memcpu_rabbitmq_qdaemon_run2.txt'
file_rmq_qd_job_run3 = './log_memcpu_rabbitmq_qdaemon_run3.txt'

# first start rabbitmq
# second start qdaemon
#   + submit ghz circuit q5
#   + submit ghz circuit qexa
#   + submit ghz circuit q20
#   + submit random_gen circuit q20
#   + submit random_gen circuit qexa
#   + submit random_gen circuit q5
# stop qdaemon
# stop rabbitmq
file_rmq_qd_keep_alive_6cirs_submission = './log_rabbitmq_qdaemon_keepalive.txt'

# read the first log file
# df_rmq_qd_job_run1 = read_prof_log(file_rmq_qd_job_run1)
# print(df_rmq_qd_job_run1)

# df_rmq_qd_job_run2 = read_prof_log(file_rmq_qd_job_run2)
# print(df_rmq_qd_job_run2)

df_rmq_qd_job_run3 = read_prof_log(file_rmq_qd_job_run3)
print(df_rmq_qd_job_run3)

# df_rmq_qd_job_keep_alive_6cirs_submit = read_prof_log(file_rmq_qd_keep_alive_6cirs_submission)
# print(df_rmq_qd_job_keep_alive_6cirs_submit)

# plot the figures
# plot_prof_data(df_rmq_qd_job_run2, "./profling_rmq_qd_job_run2.svg")
# plot_prof_data(df_rmq_qd_job_run3, "./profling_rmq_qd_job_run3.svg")
# plot_prof_data(df_rmq_qd_job_keep_alive_6cirs_submit, "./profling_rmq_qd_keepalive_6cirs_submit.svg")

# plot_prof_data(df_rmq_qd_job_run1, "./profling_rmq_qd_job_run1.pdf")
# plot_prof_data(df_rmq_qd_job_run2, "./profling_rmq_qd_job_run2.pdf")
plot_prof_data(df_rmq_qd_job_run3, "./profling_rmq_qd_job_run3.pdf")
# plot_prof_data(df_rmq_qd_job_keep_alive_6cirs_submit, "./profling_rmq_qd_keepalive_6cirs_submit.pdf")
