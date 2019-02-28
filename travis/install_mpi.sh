#!/bin/bash -xe

function latest_compiler {
    # Call it with the compiler you need to get the latest version of:
    # latest_compiler gcc
    local compiler_version=$(dpkg --list |                   # dpkg --list provides the list of packages installed on a debian based system
                           grep compiler |             # We filter only compilers and the one passed via the argument
                           grep "$1" |
                           sed -e 's/[0-9].*://' |     # Removed the `4:` from versions numbers output
                           sed 's/[[:space:]]\+/;/g' | # Changed the spaced separated columns to ;-separated.
                           awk -F';' '{print $3,$2}' | # Only print the columns needed: version (3rd) and command (2nd)
                           sort -r|                    # Sort them in reverse order and take only the first one.
                           head -n1 |
                           awk '{print $2}')           # Finally print the value of the command name.
    echo ${compiler_version}
}


function build_mpi {

    # Installed compilers
    export FC=$(latest_compiler gfortran)
    export CC=$(latest_compiler gcc)
    export CXX=$(latest_compiler g++)

    echo "Building MPI (${1}) with:"
    echo "  - FC: ${FC}"
    echo "  - CC: ${CC}"
    echo "  - CXX: ${CXX}"

    if [ -z "${FC}" ]; then
        MPICH_EXTRA='--disable-fortran'
    fi


    while sleep 540 ; do echo "=========== building ${1} is taking more than 9m - pinging travis =========="; done &
    WAIT_PID=$!

    if [[ $1 = *open* ]];
    then
	      mkdir -p openmpi
	      curl -O https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.1.tar.bz2
	      tar jxf openmpi-3.1.1.tar.bz2
	      #
	      cd openmpi-3.1.1
	      ./configure --prefix=$HOME/ci-helpers/openmpi > configure.log  2>&1
	      sudo make all install > make.log  2>&1
    else
	      mkdir -p mpich
	      # Download latest stable from mpich
	      curl -O http://www.mpich.org/static/downloads/3.2.1/mpich-3.2.1.tar.gz
	      tar zxf mpich-3.2.1.tar.gz
	      cd mpich-3.2.1
	      ./configure --prefix=$HOME/ci-helpers/mpich ${MPICH_EXTRA-} > configure.log 2>&1
	      make -j CFLAGS="-w"  > make.log 2>&1
	      sudo make install
    fi

    if [[ $? = 0 ]]; then
        # Only created the touched file when build succeed
        touch "${HOME}/ci-helpers/${1}/cached"
    else
        # show the end of the make log to show what went wrong
        tail -n100 make.log
        find "${HOME}/ci-helpers/${1}"
    fi

    kill $WAIT_PID

}

# Are we using the cache directory or it's empty?
if [ ! -f "${HOME}/ci-helpers/${1}/cached" ]
then
    pushd ${HOME}/ci-helpers
    build_mpi $1
    popd
fi
