MACHINE=ASUS
MACHINE=RYZEN
MACHINE=THREADRIPPER
MACHINE=RUCHE

FOLDER="scaling"
LOG="scaling.log"
echo "--- SCALING.sh ---" | tee $FOLDER/$LOG

STRINGCONFIGX="scaling/file/config_scaling_x_"
STRINGCONFIGY="scaling/file/config_scaling_y_"
STRINGTXT=".txt"

STRINGCONFIG=("scaling/file/config_scaling_x_" "scaling/file/config_scaling_y_")

# load spack
echo "$(tput setaf 3)Loading spack modules ...$(tput setaf 0)" | tee -a $FOLDER/$LOG
. ~/spack/share/spack/setup-env.sh
spack load intel-oneapi-mpi
echo "$(tput setaf 2)Done !$(tput setaf 0)" | tee -a $FOLDER/$LOG
echo "$(tput setaf 3)Building executable ...$(tput setaf 0)" | tee -a $FOLDER/$LOG
make clean >>/dev/null && make -j >>/dev/null
echo "$(tput setaf 2)Done !$(tput setaf 5)" | tee -a $FOLDER/$LOG

##### CONFIGURATON ####
MAX_NODE=8            #
MAX_THREAD_PER_NODE=8 #
TOTAL_CPU=8           #
#######################

#thread * node = cpu --> thread = cpu / node
echo "Configuration : " | tee -a $FOLDER/$LOG
echo "           -->  NODE         : $MAX_NODE" | tee -a $FOLDER/$LOG
echo "           -->  TOTAL CPU    : $TOTAL_CPU" | tee -a $FOLDER/$LOG
echo "           -->  CPU PER NODE : $MAX_THREAD_PER_NODE" | tee -a $FOLDER/$LOG
echo " "

################ FUNCTION COMPILATION  #######################3
function build_base() {

	echo "$(tput setaf 3)Building executable ...$(tput setaf 0)" | tee -a $FOLDER/$LOG
	make clean >>/dev/null && make CCUSELESSPART="-DUSELESSPART" CCSPLIT="-DHORIZONTAL" CCVERBOSE="-DNOVERBOSE" CCSAVEFILE="-DNOSAVEFILE" CCASSERT="-DASSERT" CCBARRIER="-DBARRIER" CCMPI="-DNAIVEMPI" CCORDER="-DSTANDARDLOOP" -j >>/dev/null
	echo "$(tput setaf 2)Done !$(tput setaf 5)" | tee -a $FOLDER/$LOG

}

function build_optimized() {

	echo "$(tput setaf 3)Building executable ...$(tput setaf 0)" | tee -a $FOLDER/$LOG
	make clean >>/dev/null && make CCUSELESSPART="-DNOUSELESSPART" CCSPLIT="-DVERTICAL" CCVERBOSE="-DNOVERBOSE" CCSAVEFILE="-DNOSAVEFILE" CCASSERT="-DNOASSERT" CCBARRIER="-DNOBARRIER" CCMPI="-DFACTORIZEDMPI" CCORDER="-DOPTIMIZEDLOOP" -j >>/dev/null
	echo "$(tput setaf 2)Done !$(tput setaf 5)" | tee -a $FOLDER/$LOG

}

################3 FUNCTION STRONG SCALIng ##########################3
# strong_scaling_MPI $NODE $THREAD_PER_NODE
function strong_scaling_MPI() {
	echo "$(tput setaf 1)--> Strong scaling MPI$(tput setaf 2)" | tee -a $FOLDER/$LOG
	echo "$(tput setaf 5)Running with $1 max nodes and $2 max threads per nodes" | tee -a $FOLDER/$LOG

	for ((NUM_NODE = 1; NUM_NODE <= $1; NUM_NODE = NUM_NODE * 2)); do
		NUM_THREAD=$2
		echo "$(tput setaf 3)NODE : $NUM_NODE , THREAD_PER_NODE : $NUM_THREAD$(tput setaf 2)" | tee -a $FOLDER/$LOG
		export OMP_NUM_THREADS=$NUM_THREAD
		mpirun -np $NUM_NODE ./lbm | grep "Average" | tee -a $FOLDER/$LOG
	done
}

# string_scaling_OMP $NODE $THREAD_PER_NODE
function strong_scaling_OMP() {
	echo "$(tput setaf 1)--> Strong scaling OMP$(tput setaf 2)" | tee -a $FOLDER/$LOG
	echo "$(tput setaf 5)Running with $1 max nodes and $2 max threads per nodes" | tee -a $FOLDER/$LOG
	for ((NUM_THREAD = 1; NUM_THREAD <= $2; NUM_THREAD = NUM_THREAD * 2)); do
		NUM_NODE=$1
		echo "$(tput setaf 3)NODE : $NUM_NODE , THREAD_PER_NODE : $NUM_THREAD$(tput setaf 2)" | tee -a $FOLDER/$LOG
		export OMP_NUM_THREADS=$NUM_THREAD
		mpirun -np $NUM_NODE ./lbm | grep "Average" | tee -a $FOLDER/$LOG
	done
}

################# FUNCTION WEAK SCALING #########################
#weak_scaling_MPI $NODE $THREAD_PER_NODE
function weak_scaling_MPI() {
	echo "$(tput setaf 1)--> Weak scaling MPI$(tput setaf 2)" | tee -a $FOLDER/$LOG
	echo "$(tput setaf 5)Running with $1 max nodes and $2 max threads per nodes" | tee -a $FOLDER/$LOG
	for DIRECTION in "${STRINGCONFIG[@]}"; do
		for ((NUM_NODE = 1; NUM_NODE <= $1; NUM_NODE = NUM_NODE * 2)); do
			NUM_THREAD=$2
			FILE=$DIRECTION$NUM_NODE$STRINGTXT
			echo "$(tput setaf 3)NODE : $NUM_NODE, THREAD_PER_NODE : $NUM_THREAD$(tput setaf 2), FILE : $FILE" | tee -a $FOLDER/$LOG
			export OMP_NUM_THREADS=$NUM_THREAD
			mpirun -np $NUM_NODE ./lbm $FILE | grep "Average" | tee -a $FOLDER/$LOG
		done
	done
}

#weak_scaling_OMP $NODE $THREAD_PER_NODE
function weak_scaling_OMP() {
	echo "$(tput setaf 1)--> Weak scaling OMP$(tput setaf 2)" | tee -a $FOLDER/$LOG
	echo "$(tput setaf 5)Running with $1 max nodes and $2 max threads per nodes" | tee -a $FOLDER/$LOG
	for DIRECTION in "${STRINGCONFIG[@]}"; do

		for ((NUM_THREAD = 1; NUM_THREAD <= $2; NUM_THREAD = NUM_THREAD * 2)); do
			NUM_NODE=$1
			FILE=$DIRECTION$NUM_THREAD$STRINGTXT

			echo "$(tput setaf 3)NODE : $NUM_NODE, THREAD_PER_NODE : $NUM_THREAD$(tput setaf 2), FILE : $FILE" | tee -a $FOLDER/$LOG
			export OMP_NUM_THREADS=$NUM_THREAD
			mpirun -np $NUM_NODE ./lbm $FILE | grep "Average" | tee -a $FOLDER/$log
		done
	done
}

################### STRONG SCALING ################
echo " " | tee -a $FOLDER/$LOG
echo "$(tput setaf 1)--- Base code ---$(tput setaf 0)" | tee -a $FOLDER/$LOG
build_base

NODE=$MAX_NODE
THREAD_PER_NODE=1
strong_scaling_MPI $NODE $THREAD_PER_NODE

NODE=1
THREAD_PER_NODE=$MAX_THREAD_PER_NODE
strong_scaling_OMP $NODE $THREAD_PER_NODE

echo " " | tee -a $FOLDER/$LOG
echo "$(tput setaf 1)--- Optimized code ---$(tput setaf 0)" | tee -a $FOLDER/$LOG
build_optimized
NODE=$MAX_NODE
THREAD_PER_NODE=1
strong_scaling_MPI $NODE $THREAD_PER_NODE

NODE=1
THREAD_PER_NODE=$MAX_THREAD_PER_NODE
strong_scaling_OMP $NODE $THREAD_PER_NODE

############# WEAK SCALING ###############
echo " " | tee -a $FOLDER/$LOG
echo "$(tput setaf 1)--- Base code --$(tput setaf 0)" | tee -a $FOLDER/$LOG
build_base

NODE=$MAX_NODE
THREAD_PER_NODE=1
weak_scaling_MPI $NODE $THREAD_PER_NODE

NODE=1
THREAD_PER_NODE=$MAX_THREAD_PER_NODE
weak_scaling_OMP $NODE $THREAD_PER_NODE

echo " " | tee -a $FOLDER/$LOG
echo "$(tput setaf 1)--- Optimized code ---$(tput setaf 0)" | tee -a $FOLDER/$LOG
build_optimized

NODE=$MAX_NODE
THREAD_PER_NODE=1
weak_scaling_MPI $NODE $THREAD_PER_NODE

NODE=1
THREAD_PER_NODE=$MAX_THREAD_PER_NODE
weak_scaling_OMP $NODE $THREAD_PER_NODE

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
