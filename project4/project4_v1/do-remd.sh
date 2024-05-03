 chmod +x do-exchange.sh
 bash step0/run-md.sh >> step0/md.log
 for i in `seq 0 999`; do
    bash ./do-exchange.sh $i >> remd.log
    bash step$((i+1))/run-md.sh >> step$((i+1))/md.log
 done