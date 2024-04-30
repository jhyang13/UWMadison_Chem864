#!/bin/bash

# Initialize log file for the exchange process
echo "Starting REMD Simulation" > remd.log

# Run the initial simulation and record its log
bash /home/jyang753/project4/S2_REMD/step_0/run-md.sh > /home/jyang753/project4/S2_REMD/step_0/md.log

# Loop through the steps from 1 to 1000, performing exchanges simulations
for i in $(seq 0 4); do

    # Run the exchange script and append its output to the log
    bash /home/jyang753/project4/S2_REMD/do-exchange.sh $i # >> remd.log

    # Run the next step's simulation and append its log
    bash /home/jyang753/project4/S2_REMD/step_$((i+1))/run-md.sh # > /home/jyang753/project4/S2_REMD/step_$((i+1))/md.log
    
done

echo "REMD Simulation completed" >> remd.log

