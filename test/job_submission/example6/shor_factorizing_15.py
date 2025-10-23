import os
import math
import argparse

from socket import gethostname

from qiskit import ClassicalRegister, QuantumRegister
from qiskit import QuantumCircuit
from hpc_offload_provider import HPCOffloadProvider

# does not need this
# os.environ["QD_REQUEST_QUEUE"] = f"qd_qrequest_reception_queue_{gethostname()}"

def circuit_amod15(qc, qr, cr, a):
    if a == 2:
        qc.cswap(qr[4], qr[3], qr[2])
        qc.cswap(qr[4], qr[2], qr[1])
        qc.cswap(qr[4], qr[1], qr[0])
    elif a == 7:
        qc.cswap(qr[4], qr[1], qr[0])
        qc.cswap(qr[4], qr[2], qr[1])
        qc.cswap(qr[4], qr[3], qr[2])
        qc.cx(qr[4], qr[3])
        qc.cx(qr[4], qr[2])
        qc.cx(qr[4], qr[1])
        qc.cx(qr[4], qr[0])
    elif a == 8:
        qc.cswap(qr[4], qr[1], qr[0])
        qc.cswap(qr[4], qr[2], qr[1])
        qc.cswap(qr[4], qr[3], qr[2])
    elif a == 11:
        qc.cswap(qr[4], qr[2], qr[0])
        qc.cswap(qr[4], qr[3], qr[1])
        qc.cx(qr[4], qr[3])
        qc.cx(qr[4], qr[2])
        qc.cx(qr[4], qr[1])
        qc.cx(qr[4], qr[0])
    elif a == 13:
        qc.cswap(qr[4],qr[3],qr[2])
        qc.cswap(qr[4],qr[2],qr[1])
        qc.cswap(qr[4],qr[1],qr[0])
        qc.cx(qr[4],qr[3])
        qc.cx(qr[4],qr[2])
        qc.cx(qr[4],qr[1])
        qc.cx(qr[4],qr[0])

def circuit_11period15(qc, qr, cr, backend_type):
    # Initialize qubit |0> to |1>
    qc.x(qr[0])

    # Apply a^4 mode N=15
    qc.h(qr[4])
    qc.h(qr[4])
    if backend_type != "QLM":
        qc.measure(qr[4], cr[0])
    qc.reset(qr[4])

    # Apply 11 mod 15
    qc.h(qr[4])
    qc.cx(qr[4], qr[3])
    qc.cx(qr[4], qr[1])
    qc.p(3*math.pi/4., qr[4]).c_if(cr, 3)
    qc.p(math.pi/2., qr[4]).c_if(cr, 2)
    qc.p(math.pi/4., qr[4]).c_if(cr, 1)
    qc.h(qr[4])
    qc.measure(qr[4], cr[2])


def circuit_aperiod15(qc, qr, cr, a, backend_type):
    if a == 11:
        circuit_11period15(qc, qr, cr, backend_type)

    # Initialize qubit |0> to |1>
    qc.x(qr[0])
    
    # Apply a^4 mode N=15
    qc.h(qr[4])
    qc.h(qr[4])
    if backend_type != "QLM":
        qc.measure(qr[4], cr[0])
    qc.reset(qr[4])

    # Apply a^2 mode N=15
    qc.h(qr[4])
    qc.cx(qr[4], qr[2])
    qc.cx(qr[4], qr[0])
    qc.p(math.pi/2., qr[4]).c_if(cr, 1)
    qc.h(qr[4])
    if backend_type != "QLM":
        qc.measure(qr[4], cr[1])
    qc.reset(qr[4])

    # Apply a mod 15
    qc.h(qr[4])
    circuit_amod15(qc, qr, cr, a)
    qc.p(3*math.pi/4., qr[4]).c_if(cr, 3)
    qc.p(math.pi/2., qr[4]).c_if(cr, 2)
    qc.p(math.pi/4., qr[4]).c_if(cr, 1)
    qc.h(qr[4])
    
    # Measure
    if backend_type != "QLM":
        qc.measure(qr[4], cr[2])


if __name__ == "__main__":

    # argument declaration
    parser = argparse.ArgumentParser()

    parser.add_argument("-bak", "--backend", type=str,
                        default="QLM",
                        help="Type of the backend we want to run")
    
    parser.add_argument("-cop", "--coprime", type=int,
                        default=7,
                        help="The coprime used to calculate factorization")
    
    args = vars(parser.parse_args())
    backend_type = args["backend"]
    a = args["coprime"]
    num_qubits = 5

    provider = HPCOffloadProvider()
    backend = provider.get_backend(backend_type)

    # define the circuit
    q = QuantumRegister(num_qubits, 'q')
    c = ClassicalRegister(num_qubits, 'c')
    shor_circuit = QuantumCircuit(q, c)
    circuit_aperiod15(shor_circuit, q, c, a, backend_type)

    # submit the quantum job
    job = backend.run(shor_circuit, shots=1000)
    print(f"Job {job.job_id()}: Submitted! Waiting for results...!")
    print(job.result().get_counts())
    print(f"------------------------------------------------------")

