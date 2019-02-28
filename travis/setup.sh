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
ci_path=${HOME}/ci-helpers
## Travis will create directory automatically if setup as cached, if not it
## needs to be created
if [ ! -d ${ci_path} ]; then
    mkdir -p ${ci_path}
fi

ci_travis="ci-helpers/travis"
### different arguments for different tools:
# - openmpi
# - spack
# - mpich
for value in "$@"; do
    case ${value} in
        openmpi)
            source ${ci_travis}/install_mpi.sh openmpi
            ;;
        mpich)
            source ${ci_travis}/install_mpi.sh mpich
            ;;
        spack)
            source ${ci_travis}/install_spack.sh
            ;;
        *)
            usage
    esac
done
