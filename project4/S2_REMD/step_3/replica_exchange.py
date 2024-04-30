import numpy as np
from scipy.constants import R

def read_last_line(filename):
    """Read the last line of a file to get the energy value."""
    with open(filename, 'r') as file:
        for line in file:
            pass
    return float(line.strip().split()[-1])

def scale_coordinates(file1, file2, scale):
    """Scale coordinates in a .gro file and write to a new file."""
    with open(file1, 'r') as old_file, open(file2, 'w') as new_file:

        header, count = old_file.readline(), old_file.readline()
        new_file.write(header + count)
        
        for line in old_file:
            if line.strip():  # Avoid processing empty lines or headers again
                parts = line.split()
                if len(parts) == 6:  # Check if line contains coordinates
                    x, y, z = map(float, parts[3:6])
                    new_file.write(f"{line[:44]}{x*scale:8.4f}{y*scale:8.4f}{z*scale:8.4f}\n")
                else:
                    new_file.write(line)

def perform_replica_exchange(file1, file2, T1, T2):
    """Wrapper function to handle coordinate scaling for two files."""
    scale_down = np.sqrt(T1/T2)
    scale_up = 1 / scale_down
    scale_coordinates(file1, 'ex_' + file2, scale_down)
    scale_coordinates(file2, 'ex_' + file1, scale_up)

def is_exchange_accepted(delta):
    """Determine whether an exchange is accepted based on the Metropolis criterion."""
    return (delta <= 0) or (np.random.uniform() < np.exp(-delta))

def main():
    temperatures = np.linspace(298, 998, 8)  # Generates 8 values from 298 to 998
    betas = 1.0e3 / (R * temperatures)
    energy_files = [f"{i+1}.xvg" for i in range(8)]
    energies = [read_last_line(file) for file in energy_files]

    # Decide randomly on pairs of replicas to attempt exchanges
    pair_indices = np.random.choice(len(energies), size=(4, 2), replace=False)
    for idx1, idx2 in pair_indices:
        delta = (betas[idx1] - betas[idx2]) * (energies[idx1] - energies[idx2])
        if is_exchange_accepted(delta):
            perform_replica_exchange(f"{idx1+1}.gro", f"{idx2+1}.gro", temperatures[idx1], temperatures[idx2])

if __name__ == "__main__":
    main()

