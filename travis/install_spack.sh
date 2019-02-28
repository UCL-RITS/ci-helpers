#!/bin/bash -xe

ci_path=${HOME}/ci-helpers
spack_path=${ci_path}/spack

pushd ${ci_path}

# Are we using the cache directory or it's empty?
if [ ! -f ${spack_path}/README.md ]; then
    rm -rf ${spack_path}
    git clone https://github.com/spack/spack.git
fi

. spack/share/spack/setup-env.sh


while sleep 540 ; do echo "=========== spack installation is taking more than 9m - pinging travis =========="; done & # cfits may take long to download
WAIT_PID=$!

spack compiler list
spack compiler remove clang@10.0.0-apple
spack compiler list
# spack install -y gcc@7.2.0
# spack compiler add `spack location -i gcc@7.2.0`
spack install -y openmpi@3.0.0

kill $WAIT_PID
popd

#load modules after installation
if [ $TRAVIS_OS_NAME = osx ]; then
    . $(brew --prefix modules)/init/bash;
fi

# Load what we need
export SPACK_ROOT=${spack_path}
. $SPACK_ROOT/share/spack/setup-env.sh

spack load openmpi@3.0.0
