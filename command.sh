#!/bin/bash
function listen() {
adinrec file.wav > /dev/null 2>&1
}


which ffmpeg && encoder="ffmpeg"
which avconv && encoder="avconv"
if [ "$encoder" == "" ];then
	echo "You need a flac encoder. Install ffmpeg or libav-tools (avconv)"
	exit 1
fi;
which julius || echo "You need julius. Install julius and julias-voxforge" && exit 1
which curl || echo "You need curl. Install it." && exit 1
which flite || echo "You need flite. Install it." && exit 1


while true; do 
listen
ACTION=$(julius -quiet -input rawfile -filelist files -C sample.jconf | grep sentence1: | sed -e 's/sentence1: <s> \(.*\) <\/s>/\1/')
case $ACTION in
	"COMP PLAY")
		flite -t "What should I play?" 
		listen
		rm file.flac  > /dev/null 2>&1
		$encoder -i file.wav -ar 16000 -acodec flac file.flac
		query="$(wget -q --post-file file.flac --header "Content-Type: audio/x-flac; rate=16000" -O - "http://www.google.com/speech-api/v1/recognize?lang=en-us" | cut -d\" -f12)"
		echo
		echo $query
		echo
		playlist="$(curl http://www.reddit.com/r/$(echo $query | awk '{print tolower($0)}' | tr -d ' ')/  | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep "http://www.youtube\|https://www.youtube" | sed 's/https:/http:/g' )" 
 		if [ "$playlist" ]; then
  			flite -t "Playing youtube links from R slash $(cat stt.txt)" 
  			printf "$playlist" | vlc - &
		else
			flite -t "No links found"
		fi
		;;
	"COMP STOP")
		flite -t "Killing VLC instances"
		pkill vlc
		;;
*)
		flite -t  "wtf..."
		;;
esac
done;
