#!/bin/bash

# usage
# ./configure <build-path> <N> <vcluster>

usage() {
    echo "./configure.sh build-path N vcluster"
    echo "      build-path: the path where the benchmarks will be configured"
    echo "      N:          the number of parallel builds to configure"
    echo "      vcluster:   the target vCluster"
}

# Ensure there are exactly 3 arguments provided
if [ "$#" -ne 3 ]; then
    echo "exactly three arguments must be provided"
    echo
    usage
    exit 1
fi

# Assign the arguments to variables
build_path="$1"
N="$2"
vcluster="$3"

build_path=$(realpath $build_path)

echo ================================================
echo == building $N instances for $vcluster
echo == targets: $build_path
echo

# set up stackinator
echo ================================================
echo == initialising stackinator
echo
(cd stackinator; ./bootstrap.sh) 2>&1 > log_configure
export PATH=$(pwd)/stackinator/bin:$PATH

echo
for i in $(seq 1 $N); do
    bpath=${build_path}/${i}
    echo ================================================
    echo "==  ($i of $N): $bpath"
    stack-config -s $(pwd)/alps-cluster-config/$vcluster -b$bpath  -r $(pwd)/recipes/gromacs
done
