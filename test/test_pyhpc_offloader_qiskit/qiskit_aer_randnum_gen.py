import matplotlib.pyplot as plt
import random, itertools
import numpy as np
import math

from random import randint

from qiskit import QuantumCircuit, ClassicalRegister, QuantumRegister, transpile
from qiskit_aer import AerSimulator
from qiskit.visualization import plot_histogram

# Declare the amount of numbers, 2^n
n = 4

q = QuantumRegister(n)
c = ClassicalRegister(n)
randnum_circ = QuantumCircuit(q, c)

for i in range(n):
    # randnum_circ.h(q[i])
    randnum_circ.rx(3.14159/(2.5 + i), q[i])

randnum_circ.measure(q, c)

simulator = AerSimulator()
transpiled_circ = transpile(randnum_circ, simulator)

# Run and get counts
result = simulator.run(transpiled_circ).result()
counts = result.get_counts(transpiled_circ)
plot_histogram(counts, title='Random Number Generator N=3')
plt.show()