 #!/bin/bash
gmx=/usr/local/gromacs/bin/gmx
python=/Users/yiwenwang/opt/anaconda3/bin/python

number_of_replicas=8
step=$1

cp remd.py ./step$step/
cd ./step$step/
$python remd.py
cd ..

for i in $(seq 1 $number_of_replicas); do
    if [ -e ./step$step/ex_$i.gro ]
    then
        mv ./step$step/ex_$i.gro ./step$((step+1))/$i.gro
    else
        cp ./step$((step))/$i.gro ./step$((step+1))/$i.gro
    fi
done

for i in $(seq 1 $number_of_replicas); do
    $gmx grompp -c ./step$((step+1))/$i.gro -p ./ala2.top -f ./tprs/remd-$i.mdp -o ./step$((step+1))/$i.tpr -maxwarn 2 >& ./step$((step+1))/exchange.out
done

ls step$((step+1))/*tpr | sed s/.tpr//g | while read fn; do
    echo $gmx mdrun -deffnm $fn
    echo echo 10 \| $gmx energy -f $fn.edr -o $fn.xvg
done > ./step$((step+1))/run-md.sh