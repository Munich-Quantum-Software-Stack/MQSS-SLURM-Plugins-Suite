from qiskit import ClassicalRegister, QuantumRegister
from qiskit import QuantumCircuit
from hpc_offload_provider import HPCOffloadProvider

if __name__ == "__main__":

    ...

    provider = HPCOffloadProvider()
    backend = provider.get_backend(„QExa20“)

    n = 20 # num_qubits

    # define the circuit
    q = QuantumRegister(n)
    c = ClassicalRegister(n)
    ghz_circ = QuantumCircuit(q, c)

    ghz_circ.h(0)
    for i in range(num_qubits - 1):
        ghz_circ.cx(i, i+1)

    ...
