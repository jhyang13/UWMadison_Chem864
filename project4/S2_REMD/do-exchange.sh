 #!/bin/bash

# Define the path to the GROMACS executable
gmx=gmx
python=/home/jyang753/project4/S2_REMD

# Define the number of replicas in the REMD simulation
number_of_replicas=8

# Get the current simulation step number from the first script argument
step=$1

# Copy the Python script that handles exchanges between replicas to the current step directory
cp replica_exchange.py /home/jyang753/project4/S2_REMD/step_$step/

# Change directory to the current step
cd /home/jyang753/project4/S2_REMD/step_$step/

#  Execute the Python script that performs the replica exchange
python /home/jyang753/project4/S2_REMD/replica_exchange.py

# Return to the parent directory
cd ..

# Loop over all replicas
for i in $(seq 1 $number_of_replicas); do

    # Check if the exchange file exists for the current replica
    if [ -e /home/jyang753/project4/S2_REMD/step_$step/ex_$i.gro ]
    then
        # If an exchange file exists, move it to the next step as the initial file for the replica
        mv /home/jyang753/project4/S2_REMD/step_$step/ex_$i.gro /home/jyang753/project4/S2_REMD/step_$((step+1))/$i.gro
    else
        # If no exchange file exists, copy the current step's file to the next step unchanged
        cp /home/jyang753/project4/S2_REMD/step_$((step))/$i.gro /home/jyang753/project4/S2_REMD/step_$((step+1))/$i.gro
    fi

done

# Loop over all replicas to prepare for the next simulation step
for i in $(seq 1 $number_of_replicas); do
    # Prepare simulation input files using grompp, specifying the configuration, topology, parameters, and output file
    $gmx grompp -c /home/jyang753/project4/S2_REMD/step_$((step+1))/$i.gro -p /home/jyang753/project4/S2_REMD/ala2.top -f /home/jyang753/project4/S2_REMD/mdp/nvt_$i.mdp -o /home/jyang753/project4/S2_REMD/step_$((step+1))/$i.tpr -maxwarn 10 >& /home/jyang753/project4/S2_REMD/step_$((step+1))/exchange.out
done

# Define the current simulation step
step=$1
next_step=$((step + 1))

# Directory for the next step's simulation files
next_step_dir="step_$next_step"

# Output script file
script_file="/home/jyang753/project4/S2_REMD/${next_step_dir}/run-md.sh"
# Start with an empty script file
echo "" > "$script_file"

# Loop over each TPR file in the next step's directory
for tpr in "/home/jyang753/project4/S2_REMD/${next_step_dir}"/*.tpr; do

    # Remove the '.tpr' extension to get the base filename
    base_filename="${tpr%.tpr}"

    # Append the GROMACS mdrun command to the script
    echo "$gmx mdrun -deffnm $base_filename" >> "$script_file"

    # Append the energy analysis command to the script
    echo "echo 10 | $gmx energy -f ${base_filename}.edr -o ${base_filename}.xvg" >> "$script_file"
done


