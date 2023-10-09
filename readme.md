# UENV storage benchmark

The objective of this benchmark is to test the impact of building programming environments on different file systems.

The benchmark can configure an arbitrary number of "build jobs", that can be run simultaneously, where each job builds a full programming environment in parallel.

## Configure Stage

The first step of running the benchmark is to configure the build environments that will be used in the benchmark.

NOTE: this is not timed as part of the benchmark.

For example, if the file system that is being tested is mounted at `$SCRATCH` on the system Pilatus:
```bash
./configure.sh $SCRATCH/uenv-benchmark 10 pilatus
```
The above will build 10 separate build paths, which can then be run concurrently.

## Benchmark Stage

The idea is to run a SLURM job that will launch N build jobs on N sockets, and measure time to build the environments.

A runner script has been created for Pilatus, that runs 2 build jobs per node (one per socket).
The following will run 10 builds concurrently, using the configuration generated above, on 5 nodes.

```
./run-pilatus.sh $SCRATCH/uenv-benchmark 10
```
