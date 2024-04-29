import numpy as np

def read_energies_and_temps(file_names, temps):
    energies = []
    for file_name in file_names:
        with open(file_name, 'r') as file:
            for line in file:
                if line.startswith('@') or line.startswith('#'):
                    continue  # Skip headers and comments
                parts = line.split()
                energy = float(parts[-1])  # Assuming energy is the last column
                energies.append(energy)
                break  # Assume the first valid line has the needed energy
    # Calculate beta for each temperature
    betas = [1 / (0.0083145 * temp) for temp in temps]
    return energies, betas

def replica_exchange(energies, betas):
    num_replicas = len(betas)
    for i in range(num_replicas - 1):
        delta = (betas[i] - betas[i + 1]) * (energies[i + 1] - energies[i])
        if np.random.rand() < np.exp(-delta):
            # Swap energies and betas to simulate exchange
            energies[i], energies[i + 1] = energies[i + 1], energies[i]
            betas[i], betas[i + 1] = betas[i + 1], betas[i]
    return energies

# Example usage
file_names = [f"replica_{i+1}_energy.xvg" for i in range(8)]
temps = [298, 399, 500, 601, 702, 803, 904, 998]  # Temperatures for replicas
energies, betas = read_energies_and_temps(file_names, temps)
energies = replica_exchange(energies, betas)




