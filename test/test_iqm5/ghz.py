import os
from socket import gethostname

from qiskit import QuantumCircuit
from hpc_offload_provider import HPCOffloadProvider
import json



os.environ["QD_REQUEST_QUEUE"] = f"qd_qrequest_reception_queue_{gethostname()}"

if __name__ == "__main__":
    _provider = HPCOffloadProvider()
    _backend = _provider.get_backend("Q5")

    _circuit = QuantumCircuit(5, 5)
    _circuit.h(0)
    _circuit.cx(0, 1)  # CNOT gate
    _circuit.cx(1, 2)  # CNOT gate
    _circuit.cx(2, 3)  # CNOT gate
    _circuit.cx(3, 4)  # CNOT gate

    _circuit.measure_all()

    _job = _backend.run(_circuit, shots=1000)
    print(f"Job {_job.job_id()} Submitted. Waiting for results...")
    print(_job.result().get_counts())
    with open('ghzJobRes.json', 'w') as fp:
        json.dump(_job, fp)


