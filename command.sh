#!/bin/bash
function listen() {
adinrec file.wav
#adinrec file.wav > /dev/null 2>&1
}


#set -x 
which ffmpeg && encoder="ffmpeg"
which avconv && encoder="avconv"
if [ "$encoder" == "" ];then
	echo "You need a flac encoder. Install ffmpeg or libav-tools (avconv)"
	exit 1
fi;
if [ ! $(which julius) ]; then
	echo "You need julius. Install julius and julias-voxforge" 
	exit 1
fi
if [ ! $(which curl) ]; then
	echo "You need curl." 
	exit 1
fi
if [ ! $(which flite) ]; then
	echo "You need flite." 
	exit 1
fi


name="JORDAN"

while true; do 
listen
ACTION=`julius -quiet -input rawfile -filelist files -C sample.jconf | grep sentence1: | sed -e 's/sentence1: <s> \(.*\) <\/s>/\1/'`
echo "heard $ACTION"
case $ACTION in
	"$name")
		let "resp = $RANDOM % 5 +1"
		case $resp in
			1) flite -t "What?" ;;
			2) flite -t "Yes?" ;;
			3) flite -t "sir!" ;;
			4) flite -t "Can I help you?" ;;
			5) flite -t "Need something?" ;;
		esac
		lastcommand="name"
		;;
	"PLAY MUSIC")
		if [ $lastcommand = "name" ]; then
			flite -t "What would you like me to play?" 
			lastcommand="PLAY MUSIC"
		else
			lastcommand=""
		fi
		;;
	"$name PLAY MUSIC")
		flite -t "What should I play?" 
		lastcommand="PLAY MUSIC"
		;;
	"STOP MUSIC")
		flite -t "Killing VLC instances"
		pkill vlc
		;;
	"$name STOP MUSIC")
		flite -t "Killing VLC instances"
		pkill vlc
		;;
	"WHAT TIME")
 		flite -t "The time is $(date "+%l:%M %p")."
		;;
	"$name WHAT TIME")
		flite -t "It is $(date "+%l:%M %p")."
		;;
	"WHAT DAY")
		flite -t "Today is $(date "+%A %B %e")"
		;;
	"$name WHAT DAY")
		flite -t "Today is $(date "+%A %B %e")"
		;;
	"COM PU TER")
		flite -t "My name is $name"
		;;
	*)
		case $lastcommand in
			"PLAY MUSIC")
				flite -t "searching"
				rm file.flac  > /dev/null 2>&1
				$encoder -i file.wav -ar 16000 -acodec flac file.flac > /dev/null 2>&1
				wget -q -U "Mozilla/5.0" --post-file file.flac --header "Content-Type: audio/x-flac; rate=16000" -O - "http://www.google.com/speech-api/v1/recognize?lang=en-us&client=chromium" | cut -d\" -f12  >stt.txt
				./playsome.sh "$(cat stt.txt)"
				lastcommand=""
				;;
			*)
				echo "Got nothin"
				lastcommand=""
				;;
		esac				
		;;
esac
done;
