CONFIG="config.txt"

. ~/spack/share/spack/setup-env.sh
spack load likwid

export OMP_NUM_THREADS=12

echo -e "\e[31mPerf measure ... \e[0m"
perf stat -d ./lbm $CONFIG

echo " "
echo -e "\e[31mLikwid measure ... (likwid-perfctr)\e[0m]"
likwid-perfctr -C 1 -g CLOCK ./lbm $CONFIG
