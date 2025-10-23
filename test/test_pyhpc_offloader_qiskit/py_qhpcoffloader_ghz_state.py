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
    
    parser.add_argument("-num", "--numqubits", type=int,
                        default=5,
                        help="The amount of numbers we want to randomly generate")
    
    args = vars(parser.parse_args())
    backend_type = args["backend"]
    num_qubits = args["numqubits"]

    provider = HPCOffloadProvider()
    backend = provider.get_backend(backend_type)

    # define the problem space
    n = num_qubits

    # define the circuit
    q = QuantumRegister(n)
    c = ClassicalRegister(n)
    ghz_circ = QuantumCircuit(q, c)

    ghz_circ.h(0)
    for i in range(num_qubits - 1):
        ghz_circ.cx(i, i+1)

    # insert a barrier
    ghz_circ.barrier()

    # Measure all of the qubits in the standard basis
    # for i in range(num_qubits):
    #     ghz_circ.measure(i, i)
    ghz_circ.measure_all()

    # submit the quantum job and get the result
    print(f"------------------------------------------------------")
    job = backend.run(ghz_circ, shots=1024)
    print(f"Job {job.job_id()}: Submitted! Waiting for results...!")
    print(f"------------------------------------------------------")
    print('')

    print(f"------------------------------------------------------")
    print(f"Measured results: ")
    print(job.result().get_counts())
    print(f"------------------------------------------------------")

