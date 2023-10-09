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

*TODO*: I will set this up when Pilatus is available again.
