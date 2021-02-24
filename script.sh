#!/bin/bash

link=$1
name=$2

mkdir $name
cd $name

download(){
	while [ 1 ]; do
		wget --retry-connrefused --waitretry=0.1 --read-timeout=20 --timeout=15 -t 0 --continue $1
	    if [ $? = 0 ]; then break; fi; # check return value, break if successful (0)
		sleep 0.1
	done;
}

download "$link/encryption-f1.key"
download "$link/encryption-f5.key"
download "$link/index-f5-v1.m3u8"
download "$link/index-f1-a1.m3u8"

segments=`cat index-f5-v1.m3u8 | wc -l`
segments=`echo $((segments/2-4))`

for ((i=1;i<=$segments;i++)); do
    download "$link/seg-$i-f5-v1.ts"
done

for ((i=1;i<=$segments;i++)); do
	download "$link/seg-$i-f1-a1.ts"
done

cp ../master.m3u8 .
python3 -m http.server &
sleep 5
youtube-dl --hls-use-mpegts --verbos --retries "infinite" --fragment-retries "infinite" "http://localhost:8000/master.m3u8"

rm *.ts
rm *.m3u8
rm *.key
