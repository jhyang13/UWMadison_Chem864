#!/bin/bash

# Defines a variable 'gmx' with the path to the GROMACS executable
gmx=gmx

# Starts a loop over numbers from 1 to 8, storing each number in variable 'i'
for i in `seq 1 8`; do

    # Calls GROMACS 'trjcat' command to concatenate trajectory files
    # $gmx trjcat -f step_?/$i.xtc step_??/$i.xtc step_???/$i.xtc -o traj$i.xtc -cat
    $gmx trjcat -f step_?/$i.xtc -o traj$i.xtc -cat

    # Calls GROMACS 'rama' command to analyze Ramachandran plots
    $gmx rama -s step_0/$i.tpr -f traj$i.xtc -o replica_$i.xvg
    
done

