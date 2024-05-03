import numpy as np
from scipy.constants import R

def read_energy_from_xvg(filename):
    with open(filename,'r') as f:
        lines = f.readlines()
        line = lines[-1]

        return float(line[14:])
    
def replica_exchange(file1, file2, T1, T2):
    '''
    Perform replica exchange and generate updated .gro files for simulation
    '''
    scale = np.sqrt(T1/T2)

    with open(file1,'r') as f1_old, open('ex_'+file2, 'w') as f2_new:
        for _ in range(2):
            line = f1_old.readline()
            f2_new.write(line)

        lines = f1_old.readlines()

        for line in lines[:-2]:
            f2_new.write(f'{line[:44]}{float(line[44:52])/scale:8.4f}{float(line[52:60])/scale:8.4f}{float(line[60:68])/scale:8.4f}{line[68:]}')

        for line in lines[-2:]:
            f2_new.write(line)

    with open(file2,'r') as f2_old, open('ex_'+file1, 'w') as f1_new:
        for _ in range(2):
            line = f2_old.readline()
            f1_new.write(line)

        lines = f2_old.readlines()

        for line in lines[:-2]:
            f1_new.write(f'{line[:44]}{float(line[44:52])*scale:8.4f}{float(line[52:60])*scale:8.4f}{float(line[60:68])*scale:8.4f}{line[68:]}')

        for line in lines[-2:]:
            f1_new.write(line)

def accept_exchange(idx1, idx2, energies, betas):
    E1 = energies[idx1]
    E2 = energies[idx2]
    beta1 = betas[idx1]
    beta2 = betas[idx2]

    delta = (beta1-beta2) * (E1-E2)
    
    if delta <= 0:
        return True
    prob = np.exp(-delta)

    if np.random.uniform() < prob:
        return True
    
    return False

energy_files = []
gro_files = []
for i in range(1,9):
    energy_files.append(f'{i}.xvg')
    gro_files.append(f'{i}.gro')

temperatures = range(298,999,100)
energies = []
for filename in energy_files:
    energies.append(read_energy_from_xvg(filename))

betas = [ 1.0e3/(R*temp) for temp in temperatures]

if np.random.uniform() < 0.5:
    trial_exchange = [(2*i,2*i+1) for i in range(4)]
else:
    trial_exchange = [(2*i+1,2*i+2) for i in range(3)]

for idx1, idx2 in trial_exchange:
    if accept_exchange(idx1, idx2, energies, betas):
        replica_exchange(gro_files[idx1],gro_files[idx2],temperatures[idx1],temperatures[idx2])