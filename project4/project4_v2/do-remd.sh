 chmod +x do-exchange.sh
 chmod +x initialize.sh
 chmod +x finalize.sh

 bash initialize.sh
 bash step0/run-md.sh >> step0/md.log
 for i in `seq 0 499`; do
    bash ./do-exchange.sh $i >> remd.log
    bash step$((i+1))/run-md.sh >> step$((i+1))/md.log
 done
 bash finalize.sh