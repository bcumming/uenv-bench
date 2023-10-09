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
echo build_path=$build_path
echo N=$N
echo vcluster=$vcluster

# set up stackinator
echo = configure stackinator

(cd stackinator; ./bootstrap.sh) 2>&1 > configure_log
export PATH=$(pwd)/stackinator/bin:$PATH

for i in $(seq 1 $N); do
    echo stack-config -s ./alps-cluster-config/$vcluster -s ${build_path}/${i}
done
