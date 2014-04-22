#!/bin/bash
mkdir ~/.playsome
cd ~/.playsome
playlist="$(curl http://www.reddit.com/r/$1/  | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep "http://www.youtube\|https://www.youtube\|http://soundcloud.com\|http://www.soundcloud.com" | sed 's/https:/http:/g' | sort | uniq | sort -R )" 
if [ "$playlist" ]; then
	echo "$playlist"
	echo "$playlist" | while read playsong; do 
		echo $playsong
		playfile="$(youtube-dl -x --get-filename $playsong)"
		echo $playfile
		youtube-dl -q -x -w "$playsong"
		cvlc "$playfile" "vlc://quit"
	done
else
	echo "No links found"
fi
