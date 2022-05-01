#fiolde of scalasca result
FOLDER="scalasca"
CONFIG="../config_scalasca.txt"

MPI_SIZE=1
export OMP_NUM_THREADS=10

echo -e "\e[31mLoading spack - scalasca ...\e[0m"
. ~/spack/share/spack/setup-env.sh
spack load gcc
spack load scalasca

echo -e "\e[31mCompiling with SCALASCA instrumentation ...\e[0m"
make clean && make SCALASCA="scalasca -instrument" -j >/dev/null

echo -e "\e[31mProfiling with Scalasca - instrument ...\e[0m"
cd $FOLDER
scalasca -analyse mpirun -np $MPI_SIZE ../lbm $CONFIG

echo -3 "\e[31mExamine data ... \e[0m"
scalasca -examine -s scorep_lbm_2x2_sum
