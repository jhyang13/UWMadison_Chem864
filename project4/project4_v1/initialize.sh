#!/bin/bash
gmx=/usr/local/gromacs/bin/gmx

for i in $(seq 0 1000); do
    mkdir step$i
done

temperatures=(298 398 498 598 698 798 898 998)

mkdir tprs
for i in $(seq 1 8); do
    cp nvt.mdp ./tprs/remd-$i.mdp
    sed -i '' -e "s/TEMPERATURE/${temperatures[$i-1]}/g" ./tprs/remd-$i.mdp
done

$gmx editconf -f ala2.pdb -o ala2.gro

cd step0
for i in $(seq 1 8); do
    $gmx grompp -c ../ala2.gro -p ../ala2.top -f ../tprs/remd-$i.mdp -o $i.tpr -maxwarn 2
done
cd ..

ls step0/*tpr | sed s/.tpr//g | while read fn; do
    echo $gmx mdrun -deffnm $fn
    echo echo 10 \| $gmx energy -f $fn.edr -o $fn.xvg
done > step0/run-md.sh
