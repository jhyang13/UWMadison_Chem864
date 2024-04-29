#!/bin/bash

# Extract dihedral angles for each replica
for i in $(seq 0 7); do
    gmx angle -f replica_${i}.xtc -n dihedrals.ndx -type dihedral -od dihedral_${i}.xvg
done

wham -i wham_input.txt -o free_energy.xvg -hist hist.xvg -bins 100 -temp 300

'''
import matplotlib.pyplot as plt
import numpy as np

# Load the free energy data calculated by WHAM
phi, psi, free_energy = np.loadtxt('free_energy.xvg', unpack=True)

# Reshape data for contour plot
phi_dim = int(np.sqrt(phi.size))
psi_dim = int(np.sqrt(psi.size))
X = phi.reshape((phi_dim, psi_dim))
Y = psi.reshape((phi_dim, psi_dim))
Z = free_energy.reshape((phi_dim, psi_dim))

# Plot the free energy landscape
plt.contourf(X, Y, Z, levels=np.linspace(Z.min(), Z.max(), 100), cmap='viridis')
plt.colorbar(label='Free energy (kJ/mol)')
plt.xlabel('ϕ dihedral angle (degrees)')
plt.ylabel('ψ dihedral angle (degrees)')
plt.title('Free Energy Landscape')
plt.show()
'''