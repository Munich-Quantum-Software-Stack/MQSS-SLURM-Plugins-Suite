import os
import math
import time
import argparse
import numpy as np
import networkx as nx

from qiskit import QuantumCircuit, transpile

# Simulator backend
from qiskit_aer import StatevectorSimulator
sim_backend = StatevectorSimulator(precision='double')

# Preparing the graph
nodes = list(range(20))
edges = [
    (0,1),
    (2,3),(3,4),(4,5),(5,6),
    (7,8),(8,9),(9,10),(10,11),
    (12,13),(13,14),(14,15),(15,16),
    (17,18),(18,19),
    (2,7),(7,12),
    (0,3),(3,8),(8,13),(13,17),
    (1,4),(4,9),(9,14),(14,18),
    (5,10),(10,15),(15,19),
    (6,11),(11,16)
]
G = nx.Graph()
G.add_edges_from(edges)
nx.draw_spring(G, with_labels=True)
subgraphs = [
    (0,1,3,4),
    (0,1,3,4,8,9),
    (0,1,3,4,8,9,2,7),
    (0,1,3,4,8,9,2,7,12,13),
    (0,1,3,4,8,9,2,7,12,13,14),
    (0,1,3,4,8,9,2,7,12,13,14,17,18),
    (0,1,3,4,8,9,2,7,12,13,14,17,18,15,19),
    (0,1,3,4,8,9,2,7,12,13,14,17,18,15,19,10),
    (0,1,3,4,8,9,2,7,12,13,14,17,18,15,19,10,5),
    (0,1,3,4,8,9,2,7,12,13,14,17,18,15,19,10,5,6,11),
    (0,1,3,4,8,9,2,7,12,13,14,17,18,15,19,10,5,6,11,16),
]

# Define the ising circuit
def get_ising_circuit(subgraph_indices, J, h, n_steps, stepsize):
    """ Ising model with interaction strength J and external field strength h
    """

    subgraph = G.subgraph(subgraph_indices)
    _ising_circuit = QuantumCircuit(G.number_of_nodes())

    for a in subgraph.nodes:
        _ising_circuit.rx(-2*h*stepsize,a)

    for a,b in subgraph.edges:
        _ising_circuit.cx(a,b)
        _ising_circuit.rz(-2*J*stepsize,b)
        _ising_circuit.cx(a,b)

    ising_circuit = QuantumCircuit(G.number_of_nodes())

    for _ in range(n_steps):
        ising_circuit.compose(_ising_circuit, inplace=True)

    ising_circuit.measure_active()

    return ising_circuit

# Main function and run experiments
if __name__ == "__main__":

    # argument declaration
    parser = argparse.ArgumentParser()

    parser.add_argument("-bak", "--backend", type=str,
                        default="sim",
                        help="Type of the backend we want to run")
    parser.add_argument("-sho", "--nshots", type=int,
                        default=100000,
                        help="The number of shots to measure")
    args = vars(parser.parse_args())
    backend_type = args["backend"]
    n_shots = args["nshots"]

    # Provider and backend to submit the circuit
    if backend_type == 'sim':
        backend = sim_backend

    # Setup for the circuit
    J,h = 1,5
    final_time = 1
    n_steps    = 20
    stepsize = final_time/n_steps
    steps = np.arange(1, n_steps+1)
    data_dict = {
        "coupling_strength":J,
        "field_strength":h,
        "steps":steps.tolist(),
        "times":(steps*stepsize).tolist(),
        "n_shots":n_shots,
        "n_steps":n_steps,
        "stepsize":stepsize,
        "final_time":final_time,
        "results":{}
    }

    # Some info for checking
    num_subgraphs = len(subgraphs)
    graph = 1

    # Timing the execution
    start_experiment = time.time()

    # Experiment loop
    for subgraph in subgraphs:
        data_dict["results"][str(tuple(subgraph))] = {}
        print(f'Submitting Graph {graph} ...')
        for step in steps:
            try:
                # create the circuit
                qc = get_ising_circuit(subgraph, J=J, h=h, n_steps=step, stepsize=stepsize)
                
                # submit and run the circuit
                if backend_type == 'sim':
                    job = execute(qc, backend, shots=n_shots)

                # wait for the result
                counts = job.result().get_counts()
                data_dict["results"][str(tuple(subgraph))][int(step)] = counts
            except:
                print(f'<!> an error ocurred at step number {step} <!>')
                data_dict["results"][str(tuple(subgraph))][int(step)] = None
        
        # increase the counter
        graph = graph + 1

    # Timing the execution
    end_experiment = time.time()
    print(f"------------------------------------------------------")
    eslaped_time = end_experiment - start_experiment
    print(f"Benchmark eslapsed time: {eslaped_time}s")
    print(f"------------------------------------------------------")

    # Write the result to file
    with open("IQM_"+backend_type+"_ising_measurements.json", 'w') as outfile:
        import json
        json.dump(data_dict, outfile)