# load spack
echo "$(tput setaf 3)Loading spack modules ...$(tput setaf 0)"
. ~/spack/share/spack/setup-env.sh
spack load intel-oneapi-mpi
echo "$(tput setaf 2)Done !$(tput setap 0)"
echo "$(tput setaf 3)Building executable ...$(tput setaf 0)"
make clean >>/dev/null && make -j >>/dev/null
echo "$(tput setaf 2)Done !$(tput setaf 5)"

##### CONFIGURATON ####
MAX_NODE=4            #
MAX_THREAD_PER_NODE=4 #
TOTAL_CPU=4           #
#######################

#thread * node = cpu --> thread = cpu / node
echo "Configuration : "
echo "           -->  NODE         : $MAX_NODE"
echo "           -->  TOTAL CPU    : $TOTAL_CPU"
echo "           -->  CPU PER NODE : $MAX_THREAD_PER_NODE"
echo " "

################ FUNCTION COMPILATION  #######################3
function build_base() {

	echo "$(tput setaf 3)Building executable ...$(tput setaf 0)"
	make clean >>/dev/null && make CCUSELESSPART="-DUSELESSPART" CCSPLIT="-DHORIZONTAL" CCVERBOSE="-DNOVERBOSE" CCSAVEFILE="-DNOSAVEFILE" CCASSERT="-DASSERT" CCBARRIER="-DBARRIER" CCMPI="-DNAIVEMPI" CCORDER="-DSTANDARDLOOP" -j >>/dev/null
	echo "$(tput setaf 2)Done !$(tput setaf 5)"

}

function build_optimized() {

	echo "$(tput setaf 3)Building executable ...$(tput setaf 0)"
	make clean >>/dev/null && make CCUSELESSPART="-DNOUSELESSPART" CCSPLIT="-DVERTICAL" CCVERBOSE="-DNOVERBOSE" CCSAVEFILE="-DNOSAVEFILE" CCASSERT="-DNOASSERT" CCBARRIER="-DNOBARRIER" CCMPI="-DFACTORIZEDMPI" CCORDER="-DOPTIMIZEDLOOP" -j >>/dev/null
	echo "$(tput setaf 2)Done !$(tput setaf 5)"

}

################3 FUNCTION STRONG SCALIng ##########################3
# strong_scaling_MPI $NODE $THREAD_PER_NODE
function strong_scaling_MPI() {
	echo "$(tput setaf 1)--> Strong scaling MPI$(tput setif 2)"
	echo "$(tput setaf 5)Running with $1 max nodes and $2 max threads per nodes"

	for ((NUM_NODE = 1; NUM_NODE <= $1; NUM_NODE++)); do
		NUM_THREAD=$2
		echo "$(tput setaf 3)NODE : $NUM_NODE , THREAD_PER_NODE : $NUM_THREAD$(tput setaf 2)"
		export OMP_NUM_THREADS=$NUM_THREAD
		mpirun -np $NUM_NODE ./lbm | grep "Average"
	done
}

# string_scaling_OMP $NODE $THREAD_PER_NODE
function strong_scaling_OMP() {
	echo "$(tput setaf 1)--> Strong scaling OMP$(tput setif 2)"
	echo "$(tput setaf 5)Running with $1 max nodes and $2 max threads per nodes"
	for ((NUM_THREAD = 1; NUM_THREAD <= $2; NUM_THREAD++)); do
		NUM_NODE=$1
		echo "$(tput setaf 3)NODE : $NUM_NODE , THREAD_PER_NODE : $NUM_THREAD$(tput setaf 2)"
		export OMP_NUM_THREADS=$NUM_THREAD
		mpirun -np $NUM_NODE ./lbm | grep "Average"
	done
}

echo " "
echo "$(tput setaf 1)--- Base code ---$(tput setaf 0)"
build_base

NODE=$MAX_NODE
THREAD_PER_NODE=1
strong_scaling_MPI $NODE $THREAD_PER_NODE

NODE=1
THREAD_PER_NODE=$MAX_THREAD_PER_NODE
strong_scaling_OMP $NODE $THREAD_PER_NODE

echo " "
echo "$(tput setaf 1)--- Optimized code ---$(tput setaf 0)"
build_optimized
NODE=$MAX_NODE
THREAD_PER_NODE=1
strong_scaling_MPI $NODE $THREAD_PER_NODE

NODE=1
THREAD_PER_NODE=$MAX_THREAD_PER_NODE
strong_scaling_OMP $NODE $THREAD_PER_NODE

#rm verification.log

#CONFIG=$(cat config_verification.txt)
#echo "$CONFIG" >>verification.log

#VERBOSE="-DNOVERBOSE"
#orientation_arr=("-DHORIZONTAL" "-DVERTICAL")
#orientation_arr=("-DVERTICAL")
#barrier_arr=("-DBARRIER" "-DNOBARRIER")
#barrier_arr=("-DNOBARRIER")
#MPI_arr=("-DNAIVEMPI" "-DFACTORIZEDMPI")
#loop_arr=("-DOPTIMIZEDLOOP")
#loop_arr=("-DSTANDARDLOOP" "-DOPTIMIZEDLOOP")

#for ORIENTATION in "${orientation_arr[@]}"; do
#	for HAVEBARRIER in "${barrier_arr[@]}"; do
#		for MPI in "${MPI_arr[@]}"; do
#			for LOOP in "${loop_arr[@]}"; do
#				##echo "$ORIENTATION $HAVEBARRIER $MPI $LOOP" >>verification.log
#				echo "$(tput setaf 5)Compilation flags : $ORIENTATION $HAVEBARRIER $MPI $LOOP"
#				make clean >/dev/null
#				make CCSPLIT=$ORIENTATION CCBARRIER=$HAVEBARRIER CCMPI=$MPI CCVERBOSE=$VERBOSE CCORDER=$LOOP -j >/dev/null
#				for rank in 1 2; do
#					for OMP_NUM in 1 2; do
#						#OMP_NUM_THREADS=$((4 / $rank))
#						#echo "OMP_NUM_THREADS : $OMP_NUM_THREADS"
#						export OMP_NUM_THREADS=$OMP_NUM
#						echo "$(tput setaf 2)OMP_NUM_THREADS : $OMP_NUM_THREADS"
#						echo "$(tput setaf 2)np : $rank$(tput setaf 1)" #>>verification.log
#						START_TIME=$SECONDS
#						mpirun -np $rank ./lbm config_verification.txt | grep "Average"
#						STOP_TIME=$SECONDS
#						ELAPSED_TIME=$(($STOP_TIME - $START_TIME))
#						#echo "time : $ELAPSED_TIME" >>verification.log
#						CHECKSUM=$(./display --checksum resultat.raw 9)
#						echo "np : $rank  time : $ELAPSED_TIME  checksum : $CHECKSUM" # >>verification.log
#						echo " "
#					done
#				done
#			done
#		done
#	done
#done
#
