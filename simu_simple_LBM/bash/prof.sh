echo -e "\e[32mWe need to run tau before ... Please wait\e[0m"

bash bash/tau.sh

echo -e "\e[31mLoading spack - tau ...\e[0m"
. ~/spack/share/spack/setup-env.sh
spack load tau

echo -e "\e[31mLaunching pProf ...\e[0m"
pprof -s
