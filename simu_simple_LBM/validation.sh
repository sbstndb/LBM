# load spack
. ~/spack/share/spack/setup-env.sh
spack load intel-oneapi-mpi

rm verification.log

CONFIG=$(cat config_verification.txt)
echo "$CONFIG" >>verification.log

VERBOSE="-DNOVERBOSE"
orientation_arr=("-DHORIZONTAL" "-DVERTICAL")
#orientation_arr=("-DVERTICAL")
barrier_arr=("-DBARRIER" "-DNOBARRIER")
MPI_arr=("-DNAIVEMPI" "-DFACTORIZEDMPI")
for ORIENTATION in "${orientation_arr[@]}"; do
	for HAVEBARRIER in "${barrier_arr[@]}"; do
		for MPI in "${MPI_arr[@]}"; do
			echo "$ORIENTATION $HAVEBARRIER $MPI" >>verification.log
			make clean && make CCSPLIT=$ORIENTATION CCBARRIER=$HAVEBARRIER CCMPI=$MPI CCVERBOSE=$VERBOSE -j
			for rank in 1 2 4; do
				#echo "np : $rank" >>verification.log
				START_TIME=$SECONDS
				mpirun -np $rank ./lbm config_verification.txt
				STOP_TIME=$SECONDS
				ELAPSED_TIME=$(($STOP_TIME - $START_TIME))
				#echo "time : $ELAPSED_TIME" >>verification.log
				CHECKSUM=$(./display --checksum resultat.raw 9)
				echo "np : $rank  time : $ELAPSED_TIME  checksum : $CHECKSUM" >>verification.log
			done
		done
	done
done
