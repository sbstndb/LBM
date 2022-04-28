# directory of resultat
VALIDATION_FOLDER="validation/"
CONFIG="config_validation.txt"
LOG="validation.log"

echo "--- VALIDATION.SH ---" | tee $VALIDATION_FOLDER/$LOG

# load spack
. ~/spack/share/spack/setup-env.sh
spack load intel-oneapi-mpi

#rm $VALIDATION_FOLDER/$LOG

VERBOSE="-DNOVERBOSE"
orientation_arr=("-DHORIZONTAL" "-DVERTICAL")
#orientation_arr=("-DVERTICAL")
#barrier_arr=("-DBARRIER" "-DNOBARRIER")
barrier_arr=("-DNOBARRIER")
MPI_arr=("-DNAIVEMPI" "-DFACTORIZEDMPI")
loop_arr=("-DOPTIMIZEDLOOP")
#loop_arr=("-DSTANDARDLOOP" "-DOPTIMIZEDLOOP")
for ORIENTATION in "${orientation_arr[@]}"; do
	for HAVEBARRIER in "${barrier_arr[@]}"; do
		for MPI in "${MPI_arr[@]}"; do
			for LOOP in "${loop_arr[@]}"; do
				##echo "$ORIENTATION $HAVEBARRIER $MPI $LOOP" >>$VALIDATION_FOLDER/$LOG
				echo "$(tput setaf 5)Compilation flags : $ORIENTATION $HAVEBARRIER $MPI $LOOP" | tee -a $VALIDATION_FOLDER/$LOG
				make clean >/dev/null
				make CCSPLIT=$ORIENTATION CCBARRIER=$HAVEBARRIER CCMPI=$MPI CCVERBOSE=$VERBOSE CCORDER=$LOOP -j >/dev/null
				for rank in 1 2; do
					for OMP_NUM in 1 2; do
						#OMP_NUM_THREADS=$((4 / $rank))
						#echo "OMP_NUM_THREADS : $OMP_NUM_THREADS"
						export OMP_NUM_THREADS=$OMP_NUM
						echo "$(tput setaf 2)OMP_NUM_THREADS : $OMP_NUM_THREADS" | tee -a $VALIDATION_FOLDER/$LOG
						echo "$(tput setaf 2)np : $rank$(tput setaf 1)" | tee -a $VALIDATION_FOLDER/$LOG
						START_TIME=$SECONDS
						mpirun -np $rank ./lbm $CONFIG | grep "Average"
						STOP_TIME=$SECONDS
						ELAPSED_TIME=$(($STOP_TIME - $START_TIME))
						#echo "time : $ELAPSED_TIME" >>$VALIDATION_FOLDER/$LOG
						CHECKSUM=$(./display --checksum resultat.raw 9)
						echo "np : $rank  time : $ELAPSED_TIME  checksum : $CHECKSUM" | tee -a $VALIDATION_FOLDER/$LOG
						echo " " | tee -a $VALIDATION_FOLDER/$LOG
					done
				done
			done
		done
	done
done
