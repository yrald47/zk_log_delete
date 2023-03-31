#!/bin/bash

DATA_PATH=$(gadmin config get System.DataRoot)
ZK_PATH=${DATA_PATH}/zk/version-2 #// ZK_PATH=/home/tigergraph/zk_logs
n_files_left=3

log_count=$(ls -ltrh ${ZK_PATH} | grep log | wc -l)
limit_files=`expr $log_count - $n_files_left`

if [[ $limit_files -gt 0 ]]; then
    echo -e "There is \033[0;32m${log_count} files found\033[0m in \033[0;34m${ZK_PATH}\033[0m, \033[0;33m${limit_files} will be deleted\033[0m, here the list:"
    ls -ltrh ${ZK_PATH} | grep log | head -${limit_files}

    #? Show the amount of storage that will reduce, and the percentage too
    size=`ls -lrts ${ZK_PATH}/log* | head -${limit_files} | awk '{ print; total += $1 }; END { print total }' | tail -n 1`

    sizeGB=$(echo "scale=1; $size / (1024 * 1024)" | bc)
    percentage=$(echo "scale=2; $sizeGB / 199.99 * 100.0" | bc) #? 200 GB = 209715200; df = 209702892 => 199.99

    echo -e "\nThe size is: ${sizeGB} GB, it will free the storage about ${percentage} %"

    echo -e "\nThis is 3 latest files that will be keep:"
    ls -ltrh ${ZK_PATH} | grep log | tail -n 3
    echo ""

    while true; do
        echo -ne "\033[0;33mAre you sure to delete these files? (y/n)\033[0m"; read yn
        case $yn in
            [Yy1]* ) FileList=`ls -1rt ${ZK_PATH}/log* | head -${limit_files}`; rm $FileList; break;;
            [Nn0]* ) exit;;
            * ) tput el;tput cuu1;tput el;; #// printf '\e[A\e[K'
        esac
    done
else
 echo -e "\033[0;34mThere are only 3 files found in ${ZK_PATH}, nothing to delete.\033[0m"
fi