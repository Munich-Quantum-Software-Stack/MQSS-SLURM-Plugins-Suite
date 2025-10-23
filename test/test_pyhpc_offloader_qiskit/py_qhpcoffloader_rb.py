import os
import math
import argparse
import numpy as np

from socket import gethostname

from qiskit import ClassicalRegister, QuantumRegister
from qiskit import QuantumCircuit
from hpc_offload_provider import HPCOffloadProvider

from qiskit_experiments.library import StandardRB, InterleavedRB
from qiskit_experiments.framework import ParallelExperiment, BatchExperiment
import qiskit.circuit.library as circuits

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

    provider = HPCOffloadProvider()
    backend = provider.get_backend(backend_type)

    lengths = np.arange(1, 800, 200)
    num_samples = 10
    seed = 1010
    qubits = [0]

    # Run an RB experiment on qubit 0
    exp1 = StandardRB(qubits, lengths, num_samples=num_samples, seed=seed)
    expdata1 = exp1.run(backend).block_for_results()
    results1 = expdata1.analysis_results()

    # View result data
    print("Gate error ratio: %s" % expdata1.experiment.analysis.options.gate_error_ratio)
    for result in results1:
        print(result)