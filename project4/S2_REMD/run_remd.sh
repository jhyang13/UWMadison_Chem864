#!/bin/bash

# GROMACS executable path
gmx=gmx 

# Prepare input files for all replicas
temps=(298 399 500 601 702 803 904 998)  # Temperatures for replicas

for i in $(seq 0 7); do
    temp=${temps[$i]}
    $gmx grompp -f nvt_${temp}.mdp -c enemin.gro -p ala2.top -o replica_${i}.tpr
done

# Run REMD simulation, including exchanges
for step in $(seq 1 1000); do

    # Run MD for each replica
    for i in $(seq 0 7); do
        $gmx mdrun -deffnm replica_${i} -s replica_${i}.tpr
        echo "Potential" | $gmx energy -f replica_${i}.edr -o replica_${i}_energy.xvg
    done
    
    # Call Python script to handle exchanges
    python replica_exchange.py

    # Apply exchanges to .tpr files if necessary (This is a placeholder)
    echo "Apply exchanges here (if .tpr files need to be swapped)"
done
