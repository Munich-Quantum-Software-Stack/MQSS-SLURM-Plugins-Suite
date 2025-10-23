import os
import math
import argparse

from socket import gethostname

from qiskit import ClassicalRegister, QuantumRegister
from qiskit import QuantumCircuit
from hpc_offload_provider import HPCOffloadProvider

# Initialize the problem graph
def init_graph_prob(num_nodes, num_edges):
    nodes = QuantumRegister(num_nodes,'nodes')
    edges = QuantumRegister(num_edges,'edges')
    phase_flip = QuantumRegister(1,'flip')
    measure = ClassicalRegister(num_nodes)
    qc = QuantumCircuit(nodes, edges, phase_flip, measure)
    qc.x(nodes[1])
    qc.h(nodes[2:4])
    qc.x(phase_flip)
    qc.h(phase_flip)
    
    return qc, nodes, edges, phase_flip, measure

# Setup edges, but this implies 3 edges and 4 nodes hardcoded?
def edge_setup(qc, nodes, edges, phase_flip): 
    # edge 0,3
    qc.x(nodes[0])
    qc.x(nodes[3])
    qc.ccx(nodes[0],nodes[3],edges[0])
    qc.x(nodes[0])
    qc.x(nodes[3])
    qc.ccx(nodes[0],nodes[3],edges[0])
    qc.barrier()
    # edge 1,2
    qc.x(nodes[1])
    qc.x(nodes[2])
    qc.ccx(nodes[1],nodes[2],edges[1])
    qc.x(nodes[1])
    qc.x(nodes[2])
    qc.ccx(nodes[1],nodes[2],edges[1])
    qc.barrier()
    # edge 2,3
    qc.x(nodes[2])
    qc.x(nodes[3])
    qc.ccx(nodes[2],nodes[3],edges[2])
    qc.x(nodes[2])
    qc.x(nodes[3])
    qc.ccx(nodes[2],nodes[3],edges[2])
    qc.barrier()

# Grover's algorithm iteration
def grover_iteration(qc, nodes):
    qc.h(nodes[:])
    qc.x(nodes[:])
    qc.h(nodes[-1])
    qc.mcx(nodes[:-1],nodes[-1])
    qc.h(nodes[-1])
    qc.x(nodes[:])
    qc.h(nodes[:])

if __name__ == "__main__":

    # argument declaration
    parser = argparse.ArgumentParser()

    parser.add_argument("-bak", "--backend", type=str,
                        default="QExa20",
                        help="Type of the backend we want to run")
    
    parser.add_argument("-nod", "--numnodes", type=int,
                        default=4,
                        help="The number of nodes")
    
    parser.add_argument("-edg", "--numedges", type=int,
                        default=3,
                        help="The number of edges")
    
    args = vars(parser.parse_args())
    backend_type = args["backend"]
    num_nodes = args["numnodes"]
    num_edges = args["numedges"]

    provider = HPCOffloadProvider()
    backend = provider.get_backend(backend_type)

    # prepare the circuit
    qc, nodes, edges, phase_flip, measure = init_graph_prob(num_nodes, num_edges)

    edge_setup(qc, nodes, edges, phase_flip)

    qc.x(edges[:])
    qc.mcx(edges[:], phase_flip[0])
    qc.x(edges[:])

    edge_setup(qc, nodes, edges, phase_flip)

    # Run grover's algorithm
    grover_iteration(qc, nodes[2:])

    # Measure the result
    qc.measure(nodes, measure)

    # submit the quantum job and get the result
    print(f"------------------------------------------------------")
    job = backend.run(qc, shots=1024)
    print(f"Job {job.job_id()}: Submitted! Waiting for results...!")
    print(f"------------------------------------------------------")
    print('')

    print(f"------------------------------------------------------")
    print(f"Measured results: ")
    print(job.result().get_counts())
    print(f"------------------------------------------------------")

