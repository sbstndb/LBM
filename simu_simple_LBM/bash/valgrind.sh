## folder of valgrind
FOLDER="valgrind"
CONFIG="config_valgrind.txt"
LOG="valgrind.log"

export OMP_NUM_THREADS=32



echo "--- VALGRIND.SH ---" | tee $FOLDER/$LOG

echo -e "\e[31mLoad Spack ...\e[0m" | tee -a $FOLDER/$LOG
. ~/spack/share/spack/setup-env.sh
spack load gcc
spack load mpich
spack load valgrind

#cd $FOLDER

echo -e "\e[31mCompilation ... \e[0m" | tee -a $FOLDER/$LOG
make clean && make -j >/dev/null
#make clean && make CCSPLIT="-DHORIZONTAL" CCMPI="-DNAIVEMPI" CCBARRIER="-DNOBARRIER" CCUSELESS="-DUSELESS" CCORDER="-DSTANDARDLOOP"   -j > /dev/null && echo "non optimized version compilated"

cd $FOLDER
echo -e "\e[31mStart Valgrind ...\e[0m" | tee -a $LOG

valgrind --log-file=valgrind.file ../lbm ../$CONFIG | tee -a $LOG
cat valgrind.file | tee -a $LOG

echo -e "\e[31mStart Callgrind...\e[0m" | tee -a $LOG
valgrind --tool=callgrind --dump-instr=yes --collect-jumps=yes ../lbm ../$CONFIG | tee -a $LOG
