#!/bin/bash

# LFin DevOps (http://lfin.kr)
#  filename: cleanupdirs.sh
# clean(remove) directory
#  

## check parametes
if [ "$#" -lt 2 ]; then
    echo "Error: Illegal number of parameters [$#]"
    echo ""
    echo "Usage: $0 directory maxage_days"
    echo ""
    echo " eg)백업디렉토리 중 30일 지난 디렉토리 삭제" 
    echo "    $0 /home/lpin/backups 30" 
    exit 1
fi

echo "--------------------"
echo "parameters"
echo " directory:[$1]"
echo " maxage_days:[$2]"
echo "--------------------"

# check log directory 
if [ ! -d ${1} ]; then 
	echo "Error: directory not exist ${1}"
	exit 1
fi

# check parameter syntax
re='^[0-9]+$'
if ! [[ ${2} =~ $re ]] ; then
   echo "Error: ${2} parameter Not a number" >&2; 
   exit 1
fi

# change directory
cd ${1}

echo "target directories"
echo "-----"
find ./ -type d -mtime +${2}
echo "-----"

echo "run remove directories"
# find and remove directory
find ./ -type d -mtime +${2} -exec rm -r {} +
