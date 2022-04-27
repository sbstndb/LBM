echo -e "\e[31mLoad Spack ...\e[0m"
. ~/spack/share/spack/setup-env.sh
spack load gcc
spack load mpich
spack load valgrind

echo -e "\e[31mCompilation ... \e[0m"
make clean && make -j >/dev/null

echo -e "\e[31mStart Valgrind ...\e[0m"
valgrind ./lbm

echo -e "\e[31mStart Callgrind...\e[0m"
valgrind --tool=callgrind --dump-instr=yes --collect-jumps=yes ./lbm
