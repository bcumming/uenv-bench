#!/bin/bash

# usage
# ./run.sh <build-path> <N>

usage() {
    echo "./run.sh build-path N"
    echo "      build-path: the path where the benchmarks will be configured"
    echo "      N:          the number of parallel builds to configure"
}

# Ensure there are exactly 3 arguments provided
if [ "$#" -ne 2 ]; then
    echo "exactly two arguments must be provided"
    echo
    usage
    exit 1
fi

# Assign the arguments to variables
build_path="$1"
N="$2"

build_path=$(realpath $build_path)

numnodes=$(python3 -c "print(($N+1)//2)")
echo ================================================
echo == running $N instances on $numnodes nodes in $build_path
echo

rm -rf "$build_path/log*"
srun -Cmc -Acsstaff -n$N -N$numnodes ./task.sh $build_path 2

grep "^== TIMING" $build_path/log*
