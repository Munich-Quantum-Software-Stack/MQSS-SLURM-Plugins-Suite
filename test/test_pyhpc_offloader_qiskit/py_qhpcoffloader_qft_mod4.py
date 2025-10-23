import os
import math
import argparse
import numpy as np

from socket import gethostname

from qiskit import ClassicalRegister, QuantumRegister
from qiskit import QuantumCircuit
from hpc_offload_provider import HPCOffloadProvider

x = QuantumRegister(4, 'input')
y = QuantumRegister(2, 'output')
meas = ClassicalRegister(4, 'meas')
qc = QuantumCircuit(x,y,meas)
qc.h(x)
qc.barrier()
# f(x) anwenden
qc.cx(x[2],y[0])
qc.cx(x[3],y[1])
qc.barrier()

# QFT
for i in range(4):
    qc.h(x[i])
    for j in range(1, 4-i):
        qc.cp(np.pi/(2**j),x[i+j],x[i]) # (Rotation, control, target)
    qc.barrier()

for i in range(int(4/2)):
    qc.swap(x[i],x[-(i+1)])
qc.barrier()
qc.measure(x, meas)

# argument declaration
parser = argparse.ArgumentParser()

parser.add_argument("-bak", "--backend", type=str,
                    default="QExa20",
                    help="Type of the backend we want to run")

args = vars(parser.parse_args())
backend_type = args["backend"]

provider = HPCOffloadProvider()
backend = provider.get_backend(backend_type)

# submit the quantum job and get the result
print(f"------------------------------------------------------")
job = backend.run(qc, shots=1024)
print(f"Job {job.job_id()}: Submitted! Waiting for results...!")
print(f"Backend: {backend_type}")
print(f"------------------------------------------------------")
print('')

print(f"------------------------------------------------------")
print(f"Measured results: ")
print(job.result().get_counts())
print(f"------------------------------------------------------")

