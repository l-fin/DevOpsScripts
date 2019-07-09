#!/bin/bash

# LFin DevOps (http://lfin.kr)
#  filename: cleanuplog.sh
# clean log script
# remove and compress(gzip)

## check parametes
if [ "$#" -lt 4 ]; then
    echo "error $# is Illegal number of parameters."
    echo "Usage: $0 log_path log_pattern log_maxage_days compress_maxage_days"
    echo ""
    echo " eg)tomcat 로그를 30일 지난파일 삭제, 7일 지난 파일 압축하기" 
    echo "    $0 /home/ubuntu/server/tomcat/logs \"*\" 30 7" 
    exit 1
fi

echo "parameters"
echo " log_path:[$1]"
echo " log_pattern:[$2]"
echo " log_maxage_days:[$3]"
echo " compress_maxage_days:[$4]"

# check log directory 
if [ ! -d ${1} ]; then 
	echo "error directory not exist ${1}"
	exit 1
fi

re='^[0-9]+$'
if ! [[ ${3} =~ $re ]] ; then
   echo "error: ${3} parameter Not a number" >&2; 
   exit 1
fi

if ! [[ ${3} =~ $re ]] ; then
   echo "error: ${4} parameter Not a number" >&2; 
   exit 1
fi

# change log directory
cd ${1}

# find and remove
find ./${2} -mtime +${3} -exec rm -f {} \;

# find and compress(gz)
find ./${2} ! -name '*.gz' -mtime +${4} -exec gzip {} \;

