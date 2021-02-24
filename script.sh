#!/bin/bash

function ProgressBar {
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")
	printf "\rProgress : [${_fill// /#}${_empty// /-}] ${_progress}%%"
}


link=$1
name=$2

mkdir $name
cd $name

download(){
	while [ 1 ]; do
		wget --retry-connrefused --waitretry=0.1 --read-timeout=20 --timeout=15 -t 0 --continue $1 2> /dev/null
	    if [ $? = 0 ]; then 
			if [ $# -eq 3 ]; then
				ProgressBar $2 $3
			fi;
			break; 
		fi; # check return value, break if successful (0)
		sleep 0.1
	done;
}

download "$link/encryption-f1.key"
download "$link/encryption-f5.key"
download "$link/index-f5-v1.m3u8"
download "$link/index-f1-a1.m3u8"

echo "Configuration files downloaded"

segments=`cat index-f5-v1.m3u8 | wc -l`
segments=`echo $((segments/2-4))`

echo "Downloading $segments video segments"

for ((i=1;i<=$segments;i++)); do
    download "$link/seg-$i-f5-v1.ts" $i $segments
done

segments=`cat index-f1-a1.m3u8 | wc -l`
segments=`echo $((segments/2-4))`

echo ""
echo "Downloading $segments audio segments"

for ((i=1;i<=$segments;i++)); do
	download "$link/seg-$i-f1-a1.ts" $i $segments
done

cp ../master.m3u8 .
python3 -m http.server &
pid=$!
sleep 5
youtube-dl --hls-use-mpegts --verbos --retries "infinite" --fragment-retries "infinite" "http://localhost:8000/master.m3u8"

kill $pid
rm *.ts
rm *.m3u8
rm *.key
