#!/bin/bash

VERSION=29Oct2020
wget https://github.com/lammps/lammps/archive/stable_${VERSION}.tar.gz
tar zxf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build && cd build

module purge
module load intel/19.1.1.217
module load intel-mpi/intel/2019.7

cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local \
-D CMAKE_BUILD_TYPE=Release \
-D LAMMPS_MACHINE=user_intel \
-D ENABLE_TESTING=no \
-D BUILD_OMP=yes \
-D BUILD_MPI=yes \
-D CMAKE_Fortran_COMPILER=/opt/intel/compilers_and_libraries_2020.1.217/linux/bin/intel64/ifort \
-D CMAKE_C_COMPILER=icc \
-D CMAKE_CXX_COMPILER=icpc \
-D CMAKE_CXX_FLAGS_RELEASE="-Ofast -std=c++11 -xHost -DNDEBUG" \
-D PKG_MOLECULE=yes -D PKG_RIGID=yes -D PKG_MISC=yes \
-D PKG_KSPACE=yes -D FFT=MKL -D FFT_SINGLE=yes \
-D PKG_USER-INTEL=yes -D INTEL_ARCH=cpu -D INTEL_LRT_MODE=threads ../cmake

make -j 16
make install