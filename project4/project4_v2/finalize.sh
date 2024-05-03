#!/bin/bash
gmx=/usr/local/gromacs/bin/gmx

for i in `seq 1 8`; do
    $gmx trjcat -f step?/$i.xtc step??/$i.xtc step???/$i.xtc -o traj$i.xtc -cat
    $gmx rama -s step0/$i.tpr -f traj$i.xtc -o replica_$i.xvg
done