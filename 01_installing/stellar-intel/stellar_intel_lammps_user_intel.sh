#!/bin/bash
  
# build a double precision version of lammps for stellar-intel

VERSION=29Oct2020
wget https://github.com/lammps/lammps/archive/stable_${VERSION}.tar.gz
tar zxf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build
cd build

module purge
module load intel/2021.1.2 intel-mpi/intel/2021.1.1

cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=double -D ENABLE_TESTING=yes \
-D CMAKE_Fortran_COMPILER=/opt/intel/oneapi/compiler/2021.1.2/linux/bin/intel64/ifort \
-D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_CXX_COMPILER=icpc -D CMAKE_BUILD_TYPE=Release \
-D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHost -DNDEBUG" \
-D PKG_USER-OMP=yes -D PKG_MOLECULE=yes -D PKG_RIGID=yes \
-D PKG_KSPACE=yes -D FFT=MKL -D FFT_SINGLE=no ../cmake

make -j 10
make test
make install