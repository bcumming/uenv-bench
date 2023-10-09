#!/bin/bash

base_path=$1
ranks_per_node=$2

export LOCAL_RANK=$SLURM_LOCALID
export GLOBAL_RANK=$SLURM_PROCID
logfile="$base_path/log_${GLOBAL_RANK}"

if [ "$ranks_per_node" -eq 1 ]
then
    export NUMANODES="0,1,2,3"
    export JOBWIDTH=64
elif [ $ranks_per_node -eq 2 ]
then
    nodemap=("0,1,2,3" "4,5,6,7")
    export NUMANODES=${nodemap[$LOCAL_RANK]}
    export JOBWIDTH=64
elif [ $ranks_per_node -eq 4 ]
then
    nodemap=("0,1" "2,3" "4,5" "6,7")
    export NUMANODES=${nodemap[$LOCAL_RANK]}
    export JOBWIDTH=32
fi

run_path="$base_path/$(($GLOBAL_RANK + 1))"

echo == rankinfo: $LOCAL_RANK of $GLOBAL_RANK > $logfile 2>&1
echo == buildtasks: $JOBWIDTH >> $logfile 2>&1
echo == numanodes: $NUMANODES >> $logfile 2>&1
echo == path: $run_path >> $logfile 2>&1

if [ ! -e "$run_path" ]; then
    echo "ERROR: path $run_path does not exist" >> $logfile 2>&1
    exit 1
fi

cd $run_path
echo "== STARTING $(date)" >> $logfile 2>&1
start_ts=$(date +"%s")
echo numactl --cpunodebind=$NUMANODES --membind=$NUMANODES env --ignore-environment PATH=/usr/bin:/bin:$(pwd)/spack/bin make store.squashfs -j$JOBWIDTH >> $logfile 2>&1

pwd >> $logfile
numactl --cpunodebind=$NUMANODES --membind=$NUMANODES pwd >> $logfile 2>&1
numactl --cpunodebind=$NUMANODES --membind=$NUMANODES env --ignore-environment PATH=/usr/bin:/bin:$(pwd)/spack/bin pwd >> $logfile 2>&1

#numactl --cpunodebind=$NUMANODES --membind=$NUMANODES env --ignore-environment PATH=/usr/bin:/bin:$(pwd)/spack/bin make store.squashfs -j$JOBWIDTH >> $logfile 2>&1

end_ts=$(date +"%s")
echo "== STOPPING $(date)" >> $logfile 2>&1
total_time=$(python3 -c "print($end_ts-$start_ts)")
echo "== TIMING: $total_time seconds" >> $logfile 2>&1

