import os
import math
import time
import argparse

from qiskit import ClassicalRegister, QuantumRegister
from qiskit import QuantumCircuit, transpile
from hpc_offload_provider import HPCOffloadProvider

def get_GHZ_circuit(n_qubits, backend):
    qc = QuantumCircuit(n_qubits)
    qc.h(0)
    for i in range(1, n_qubits):
        qc.cx(0, i)
    qc.measure_all()
    # qc = transpile(qc, backend=backend)
    return qc

if __name__ == "__main__":

    # argument declaration
    parser = argparse.ArgumentParser()

    parser.add_argument("-bak", "--backend", type=str,
                        default="QExa20",
                        help="Type of the backend we want to run")
    parser.add_argument("-num", "--nqubits", type=int,
                        default=20,
                        help="Maximum number of qubits")
    parser.add_argument("-sho", "--nshots", type=int,
                        default=32000,
                        help="The number of shots to measure")
    
    args = vars(parser.parse_args())
    backend_type = args["backend"]
    max_qubits = args["nqubits"]
    n_shots = args["nshots"]

    provider = HPCOffloadProvider()
    backend = provider.get_backend(backend_type)

    ghz_results = {}
    qc_res_times = []
    qc_sub_times = []

    start_job_submission = time.time()
    for n_qubits in range(1, max_qubits+1): # upto 20 qubits
        qc = get_GHZ_circuit(n_qubits, backend)
        # job = execute(qc, backend_real, shots=n_shots)

        start_submit_each_qc = time.time()

        job = backend.run(qc, shots=n_shots)
        print(f"------------------------------------------------------")
        print(f"Backend: {backend_type}")
        print(f"Job {job.job_id()}: Submitted, n_qubits={n_qubits}, n_shots={n_shots}! Results ...!")
        print(f"------------------------------------------------------")
        print("")

        after_submit = time.time()

        counts = job.result().get_counts()

        after_get_results = time.time()

        eslaped_time_qc_submit = after_submit - start_submit_each_qc

        eslaped_time_qc_resuls = after_get_results - start_submit_each_qc

        qc_res_times.append(eslaped_time_qc_resuls)
        qc_sub_times.append(eslaped_time_qc_submit)

        print(f"Measured results: ")
        print(job.result().get_counts())
        print(f"------------------------------------------------------")
        print("")
        ghz_results[n_qubits] = counts

    end_job_submission = time.time()

    print(f"------------------------------------------------------")
    eslaped_time_benchmark = end_job_submission - start_job_submission
    print(f"Benchmark eslapsed time: {eslaped_time_benchmark}s")

    with open("IQM_"+backend_type+"_GHZ_measurements.json", 'w') as outfile:
        import json
        json.dump(ghz_results, outfile)

    print("QC Submission Time: ", qc_sub_times)
    print("QC Execution Time: ", qc_res_times)

    # with open("IQM_"+backend_type+"_subtime_measurements.txt", 'w') as subtime_outfile:
    #     import json
    #     json.dump(qc_sub_times, subtime_outfile)

    # with open("IQM_"+backend_type+"_exetime_measurements.txt", 'w') as exetime_outfile:
    #     import json
    #     json.dump(qc_res_times, exetime_outfile)


