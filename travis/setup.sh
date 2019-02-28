#!/bin/bash -xe

usage(){
	  echo "Usage: $0 package-list"
    echo ""
    echo "  package-list (any or few from) openmpi mpich spack"
    echo "Example: $0 spack mpich"
	  exit 1
}


[[ $# -eq 0 ]] && usage

########### Setup directories

## Travis will create directory automatically if setup as cached, if not it
## needs to be created
if [ ! -d ${HOME}/ci-helpers ]; then
    mkdir -p ${HOME}/ci-helpers
fi


### different arguments for different tools:
# - openmpi
# - spack
# - mpich

for value in "$@"; do
    case ${value} in
        openmpi)
            install_openmpi
            ;;
        mpich)
            install_mpich
            ;;
        spack)
            install_spack
            ;;
        *)
            usage
    esac
done
