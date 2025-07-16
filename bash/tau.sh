#fiolde of tau result
FOLDER="tau"
CONFIG="config_tau.txt"

NUM_NODE=8
export OMP_NUM_THREADS=1


echo -e "\e[31mLoading spack - tau ...\e[0m"
. ~/spack/share/spack/setup-env.sh
spack load openmpi
spack load openmpi /lomsit5
spack load tau

echo -e "\e[31mCompiling ...\e[0m"
## optimized or naive version
make clean && make -j >/dev/null
#make clean && make CCSPLIT="-DHORIZONTAL" CCMPI="-DNAIVEMPI" CCBARRIER="-DBARRIER" CCUSELESS="-DUSELESS" CCORDER="-DOPTIMIZEDLOOP" -j >/dev/null
#make clean && make CCSPLIT="-DHORIZONTAL" CCMPI="-DFACTORIZEDMPI" CCBARRIER="-DNOBARRIER" CCUSELESS="-DNOUSELESS" CCORDER="-DSTANDARDLOOP" -j >/dev/null


echo -e "\e[31mRuntime profiling ...\e[0m"

export TAU_PROFILE=1
cd $FOLDER
mpirun -np $NUM_NODE tau_exec ../lbm ../$CONFIG

echo -e "\e[31mTracing for JUMPSHOT ...\e[0m"
export TAU_TRACE=1
mpirun -np $NUM_NODE tau_exec ../lbm ../$CONFIG

echo -e "\e[31mMerge traces for Jumpshot ...\e[0m"
tau_treemerge.pl
tau2slog2 tau.trc tau.edf -o tau.slog2

echo -e "\e[31mMerge traces for VAMPIR ...\e[0m"
export TAU_TRACE_FORMAT=otf2
echo -e "\e[31mTracing for Vampir ...\e[0m"
mpirun -np $NUM_NODE tau_exec ../lbm ../$CONFIG
#echo "Papi ..."
#papi_avail
