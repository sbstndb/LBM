# load spack
. ~/spack/share/spack/setup-env.sh
spack load intel-oneapi-mpi

rm verification.log

VERBOSE="-DVERBOSE"
orientation_arr=("-DHORIZONTAL" "-DVERTICAL")
barrier_arr=("-DBARRIER" "-DNOBARRIER")
MPI_arr=("-DNAIVEMPI" "-DFACTORIZEDMPI")
for ORIENTATION in "${orientation_arr[@]}"; do
	for HAVEBARRIER in "${barrier_arr[@]}"; do
		for MPI in "${MPI_arr[@]}"; do
			echo "$ORIENTATION $HAVEBARRIER $MPI" >>verification.log
			make clean && make CCSPLIT=$ORIENTATION CCBARRIER=$HAVEBARRIER CCMPI=$MPI CCVERBOSE=$VERBOSE -j
			for rank in 1 2; do
				mpirun -np $rank ./lbm config_verification.txt
				./display --checksum resultat.raw 9 >>verification.log
			done
		done
	done
done
