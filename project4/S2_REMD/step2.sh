#!/bin/bash

# Initialize log file for the exchange process
echo "Starting REMD Simulation" > remd.log

# Run the initial simulation
bash /home/jyang753/project4/S2_REMD/step_0/run-md.sh

# Loop through the steps from 1 to 1000, performing exchanges simulations
for i in $(seq 0 499); do

    # Run the exchange script
    bash /home/jyang753/project4/S2_REMD/do-exchange.sh $i

    # Run the next step's simulation
    bash /home/jyang753/project4/S2_REMD/step_$((i+1))/run-md.sh
    
done

echo "REMD Simulation completed" >> remd.log

