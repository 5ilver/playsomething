#!/bin/bash
playlist="$(curl http://www.reddit.com/r/$1/  | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep "http://www.youtube\|https://www.youtube" | sed 's/https:/http:/g' | sort | uniq | sort -R )" 
if [ "$playlist" ]; then
	#printf $playlist
	playsong="$(printf $playlist | head -1)"
	#echo $playsong
	playfile="$(youtube-dl -x --get-filename $playsong)"
	#echo $playfile
	youtube-dl -q -x -w "$playsong"
	cvlc -q "$playfile" "vlc://quit"
else
	exit 2
fi
