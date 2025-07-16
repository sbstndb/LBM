FOLDER_BASH="bash"

echo -e "\e[32mMonitoring ...\e[0m"
bash $FOLDER_BASH/monitor.sh

echo -e "\e[32mExecuting TAU ...\e[0m"
bash $FOLDER_BASH/tau.sh

echo -e "\e[32mExecuting VALGRIND ...\e[0m"
bash $FOLDER_BASH/valgrind.sh

echo -e "\e[32mExecuting validation ...\e[0m"
bash $FOLDER_BASH/validation.sh

echo -e "\e[32mExecutinh results ...\e[0m"
bash $FOLDER_BASH/scaling.sh
