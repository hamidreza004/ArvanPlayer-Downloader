#!/bin/bash

link=$1
name=$2

mkdir $name
cd $name

download(){
	while [ 1 ]; do
		wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 0 --continue $1
	    if [ $? = 0 ]; then break; fi; # check return value, break if successful (0)
		sleep 1s;
	done;
}

download "$link/encryption-f1.key"
download "$link/encryption-f5.key"
download "$link/index-f5-v1.m3u8"
download "$link/index-f1-a1.m3u8"

segments=`cat index-f5-v1.m3u8 | wc -l`
segments=`echo $((segments/2-5))`

#for i in {1..50}; do
#    echo "$link/seg-$i-f5-v1.ts"
#done
echo $segments
