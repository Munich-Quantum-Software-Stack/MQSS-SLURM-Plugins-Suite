import os
import math
import argparse

from socket import gethostname

from qiskit import ClassicalRegister, QuantumRegister
from qiskit import QuantumCircuit
from hpc_offload_provider import HPCOffloadProvider

if __name__ == "__main__":

    # argument declaration
    parser = argparse.ArgumentParser()

    parser.add_argument("-bak", "--backend", type=str,
                        default="QExa20",
                        help="Type of the backend we want to run")
    
    parser.add_argument("-num", "--number", type=int,
                        default=5,
                        help="The amount of numbers we want to randomly generate")
    
    args = vars(parser.parse_args())
    backend_type = args["backend"]
    nums = args["number"]

    provider = HPCOffloadProvider()
    backend = provider.get_backend(backend_type)

    # define the problem space
    n = nums

    # define the circuit
    q = QuantumRegister(n)
    c = ClassicalRegister(n)
    randnum_circ = QuantumCircuit(q, c)

    for i in range(n):
        # randnum_circ.h(q[i])
        randnum_circ.rx(3.14159/(2.5 + i), q[i])

    if backend_type != "QLM":
        randnum_circ.measure(q, c)

    # submit the quantum job
    job = backend.run(randnum_circ, shots=1000)
    print(f"Job {job.job_id()}: Submitted! Waiting for results...!")
    print(job.result().get_counts())
    print(f"------------------------------------------------------")
