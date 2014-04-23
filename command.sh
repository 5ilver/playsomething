#!/bin/bash
function listen() {
rm -rf file.wav > /dev/null 2>&1
adinrec -lv 3000 file.wav > /dev/null 2>&1
}

function julius_speech() {
command=`julius -quiet -input rawfile -filelist files -C sample.jconf | grep sentence1: | sed -e 's/sentence1: <s> \(.*\) <\/s>/\1/'`
ACTION=$command
echo "Julius heard $command"

if [ "${command#$name}" == "$command" ]; then
	namesaid="false"
	echo "Didn't hear my name though"
else
	namesaid="true"
	command="${command#$name }"
	echo "Heard my name. New command \"$command\""
fi
if [ "$lastcommand" == "$name" ]; then
	echo "last command was my name, setting command name flag true"
	namesaid="true"
fi
}

function google_speech() {
rm file.flac -rf > /dev/null 2>&1
rm stt.txt -rf > /dev/null 2>&1
$encoder -i file.wav -ar 16000 -acodec flac file.flac > /dev/null 2>&1
query=`wget -q -U "Mozilla/5.0" --post-file file.flac --header "Content-Type: audio/x-flac; rate=16000" -O - "http://www.google.com/speech-api/v1/recognize?lang=en-us&client=chromium" | cut -d\" -f12`
echo "Google heard $query"
}

#set -x 
which ffmpeg && encoder="ffmpeg"
which avconv && encoder="avconv"
if [ "$encoder" == "" ];then
	echo "You need a flac encoder. Install ffmpeg or libav-tools (avconv) packages."
	exit 1
fi;
if [ ! $(which julius) ]; then
	echo "You need julius. Install julius and julias-voxforge packages." 
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
if [ ! $(which cvlc) ]; then
	echo "You need cvlc. Install vlc package." 
	exit 1
fi
if [ ! $(which youtube-dl) ]; then
	echo "You need youtube-dl. Install it from http://rg3.github.io/youtube-dl/" 
	exit 1
fi


name="JORDAN"

while true; do 
listen
julius_speech
case $command in
	"PLAY MUSIC")
		echo "Playing music!"
		if [ "$namesaid" == "true" ]; then
			flite -t "What would you like me to play?" 
			lastcommand="$command"
		else
			echo "Need to hear my name to play music"
			lastcommand=""
		fi
		;;
	"STOP MUSIC")
		flite -t "Killing VLC instances"
		pkill vlc
		;;
	"WHAT TIME")
 		flite -t "The time is $(date "+%l:%M %p")."
		;;
	"WHAT DAY")
		flite -t "Today is $(date "+%A %B %e")"
		;;
	"COM PU TER")
		flite -t "My name is $name"
		;;
	"$name")
		let "resp = $RANDOM % 5 +1"
		case $resp in
			1) flite -t "What?" ;;
			2) flite -t "Yes?" ;;
			3) flite -t "sir!" ;;
			4) flite -t "Can I help you?" ;;
			5) flite -t "Need something?" ;;
		esac
		
		lastcommand="$command"
		;;
		
	*)
		case $lastcommand in
			"PLAY MUSIC")
				flite -t "searching"
				google_speech
				./playsome.sh "$query"
				lastcommand=""
				;;
			*)
				lastcommand=""
				;;
		esac				
		;;
esac
done;
