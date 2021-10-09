# Della-GPU

It is proving difficult to find a procedure to build LAMMPS that performs optimally on della-gpu. Right now it appears the best approach is to use the [NGC container](https://ngc.nvidia.com/catalog/containers/hpc:lammps) with 1 CPU-core and 1 GPU.

### NGC Container

The [NGC container](https://ngc.nvidia.com/catalog/containers/hpc:lammps) provides the following packages:

```
ASPHERE KOKKOS KSPACE MANYBODY MISC MOLECULE MPIIO REPLICA RIGID SNAP USER-REAXC
```

Obtain the image:

```
$ ssh <YourNetID>@della-gpu.princeton.edu
$ mkdir -p software/lammps_container
$ cd software/lammps_container
$ singularity pull docker://nvcr.io/hpc/lammps:10Feb2021
```

```
#!/bin/bash
#SBATCH --job-name=lammps        # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=8G         # memory per cpu-core (4G per cpu-core is default)
#SBATCH --gres=gpu:1             # number of gpus per node
#SBATCH --time=00:10:00          # total run time limit (HH:MM:SS)

set -euf -o pipefail
# set -e (exit immediately if any line in the script fails)
# set -u (references to undefined variables produce error)
# set -f (disable filename expansion)
# set -o pipefail (return error code of failed commands in the pipeline)

# number of GPUs per node
gpu_count=$(printf ${SLURM_JOB_GPUS} | sed 's/[^0-9]*//g' | wc --chars)

module purge
#module load openmpi/gcc/4.1.0
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

singularity run --nv -B $PWD:/host_pwd --pwd /host_pwd $HOME/software/lammps_container/lammps_10Feb2021.sif ./run_lammps.sh

#srun --mpi=pmi2 \
#singularity run --nv -B $PWD:/host_pwd --pwd /host_pwd lammps_10Feb2021.sif \
#lmp -k on g ${gpu_count} -sf kk -pk kokkos cuda/aware on neigh full comm device binsize 2.8 -in in.melt
```

Make `run_lammps.sh` executable:

```
$ chmod u+x run_lammps.sh
```

Below is the contents of run_lammps.sh:

```
$ cat run_lammps.sh

#!/bin/bash
set -euf -o pipefail
readonly gpu_count=${1:-$(nvidia-smi --list-gpus | wc -l)}

echo "Running Lennard Jones 8x4x8 example on ${gpu_count} GPUS..."
mpirun -n ${gpu_count} lmp -k on g ${gpu_count} -sf kk -pk kokkos cuda/aware on neigh full comm device binsize 2.8 -in in.melt
```

### Build from Source

```
$ ssh <YourNetID>@della-gpu.princeton.edu
$ cd software  # or another directory
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/della-gpu/della_gpu_lammps_double_gcc.sh
$ bash della_gpu_lammps_double_gcc.sh | tee lammps.log
```

Be sure include the environments modules in the Bash script in your Slurm script (except cmake). You should find that all the tests pass when installing. The procedure above does everything in double precision which is probably unnecessary for your work. Attempts to use single precision FFTs and GPU kernels led to tests failing because of very slight differences in calculated versus expected values. The processors on the GPU nodes of Della are AMD. The user-intel can be used (even though processors are AMD) but it produces failed unit tests. Write to cses@princeton.edu to find the best way to use LAMMPS on della-gpu.