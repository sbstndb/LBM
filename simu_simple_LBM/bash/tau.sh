#fiolde of tau result
FOLDER="tau"
CONFIG="config_tau.txt"

echo -e "\e[31mLoading spack - tau ...\e[0m"
. ~/spack/share/spack/setup-env.sh
spack load tau

echo -e "\e[31mCompiling ...\e[0m"
make clean && make -j >/dev/null

echo -e "\e[31mRuntime profiling ...\e[0m"
export TAU_PROFILE=1
cd $FOLDER
mpirun -np 2 tau_exec ../lbm ../$CONFIG

echo -e "\e[31mTracing ...\e[0m"
export TAU_TRACE=1
mpirun -np 2 tau_exec ../lbm ../$CONFIG

echo -e "\e[31mMerge traces for Jumpshot ...\e[0m"
tau_treemerge.pl
tau2slog2 tau.trc tau.edf -o tau.slog2

echo -e "\e[31mMerge traces for Vampir ...\e[0m"
tau2otf2 tau.trc tau.edf vampir_output

#echo "Papi ..."
#papi_avail
