import numpy as np
import matplotlib.pyplot as plt

from PIL import Image
from IPython.display import display

from qiskit import QuantumCircuit, ClassicalRegister, QuantumRegister, transpile
from qiskit_aer import AerSimulator
from qiskit.visualization import plot_histogram

plumber = {(0, 0): (255, 255, 255), (0, 1): (255, 255, 255), (0, 2): (255, 255, 255), (0, 3): (255, 0, 0), 
           (0, 4): (255, 0, 0), (0, 5): (255, 0, 0), (0, 6): (255, 255, 255), (0, 7): (92, 64, 51), 
           (1, 0): (255, 255, 255), (1, 1): (255, 0, 0), (1, 2): (255, 255, 255), (1, 3): (0, 0, 255), 
           (1, 4): (0, 0, 255), (1, 5): (0, 0, 255), (1, 6): (0, 0, 255), (1, 7): (92, 64, 51), 
           (2, 0): (255, 0, 0), (2, 1): (255, 0, 0), (2, 2): (255, 192, 203), (2, 3): (255, 0, 0), 
           (2, 4): (0, 0, 255), (2, 5): (0, 0, 255), (2, 6): (255, 255, 255), (2, 7): (255, 255, 255),
           (3, 0): (255, 0, 0), (3, 1): (255, 0, 0), (3, 2): (255, 192, 203), (3, 3): (255, 0, 0), 
           (3, 4): (0, 0, 255), (3, 5): (0, 0, 255), (3, 6): (255, 255, 255), (3, 7): (255, 255, 255), 
           (4, 0): (255, 255, 255), (4, 1): (255, 0, 0), (4, 2): (255, 255, 255), (4, 3): (0, 0, 255), 
           (4, 4): (0, 0, 255), (4, 5): (0, 0, 255), (4, 6): (0, 0, 255), (4, 7): (92, 64, 51), 
           (5, 0): (255, 255, 255), (5, 1): (255, 255, 255), (5, 2): (255, 255, 255), (5, 3): (255, 0, 0), 
           (5, 4): (255, 0, 0), (5, 5): (255, 0, 0), (5, 6): (255, 255, 255), (5, 7): (92, 64, 51), 
           (6, 0): (255, 255, 255), (6, 1): (255, 255, 255), (6, 2): (255, 255, 255), (6, 3): (255, 255, 255), 
           (6, 4): (255, 255, 255), (6, 5): (210, 180, 140), (6, 6): (255, 255, 255), (6, 7): (255, 255, 255), 
           (7, 0): (255, 255, 255), (7, 1): (255, 255, 255), (7, 2): (255, 255, 255), (7, 3): (107, 92, 72), 
           (7, 4): (210, 180, 140), (7, 5): (107, 92, 72), (7, 6): (255, 255, 255), (7, 7): (255, 255, 255)}

# ---------------------------------------------------
# Classical animation image generation
# ---------------------------------------------------

def save_image(image, filename='image.png', scale=None):

    img = Image.new('RGB', (8, 8))
    for x in range(img.size[0]):
        for y in range(img.size[1]):
            img.load()[x,y] = image[x,y]

    if scale:
        img = img.resize((256, 256))

    img.save('outputs/'+filename)

save_image(plumber, scale=[300, 300], filename='classic_image_gen.png')
display(Image.open('./outputs/classic_image_gen.png'))


# ---------------------------------------------------
# Quantum animation image generation
# ---------------------------------------------------

n = 6
L = int(2**(n/2))
grid = {}
for y in range(L):
    for x in range(L):
        grid[(x, y)] = ''

for (x, y) in grid:
    for j in range(n):
        if (j%2) == 0:
            xx = np.floor(x/2**(j/2))
            grid[(x, y)] = str(int((xx + np.floor(xx/2)) % 2)) + grid[(x, y)]
        else:
            yy = np.floor(y/2**((j-1)/2))
            grid[(x, y)] = str(int((yy + np.floor(yy/2)) % 2)) + grid[(x, y)]

# Extract image pixels to quantum states
def image2state(image, grid):
    N = len(grid)
    state = [[0]*N,[0]*N,[0]*N] # different states for R, G and B

    for pos in image:
        for j in range(3):
            # amplitude is square root of colour value
            state[j][int(grid[pos], 2)] = np.sqrt(image[pos][j])

    for j in range(3):
        Z = sum(np.absolute(state[j])**2)
        # amplitudes are normalized
        state[j] = [amp / np.sqrt(Z) for amp in state[j]]

    return state

state = image2state(plumber, grid)


def ket2counts(ket):
    counts = {}
    N = len(ket)

    # figure out the qubit number that this state describes
    n = int( np.log(N)/np.log(2) ) 
    for j in range(N):
        string = bin(j)[2:]
        string = '0'*(n-len(string)) + string
        # square amplitudes to get probabilities
        counts[string] = np.absolute(ket[j])**2 

    return counts

# Define backend for simulation
simulator = AerSimulator()
q = QuantumRegister(n)
counts = []

# Notes: j=0 for red, j=1 for green, j=2 for blue
for j in range(3):
    qc = QuantumCircuit(q)
    qc.initialize(state[j], q)
    qc.measure(q)

    transpiled_circ = transpile(qc, simulator)

    # Run and get counts
    result = simulator.run(transpiled_circ).result()
    counts = result.get_counts(transpiled_circ)
    counts.append(ket2counts(result.get_statevector()))

print(counts)
