#!/bin/bash
function listen() {
adinrec file.wav > /dev/null 2>&1
}


#set -x 
which ffmpeg && encoder="ffmpeg"
which avconv && encoder="avconv"
if [ "$encoder" == "" ];then
	echo "You need a flac encoder. Install ffmpeg or libav-tools (avconv)"
	exit 1
fi;
#which julius || echo "You need julius. Install julius and julias-voxforge" && exit 1
#which curl || echo "You need curl. Install it." && exit 1
#which flite || echo "You need flite. Install it." && exit 1


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
				playlist="$(curl http://www.reddit.com/r/$(cat stt.txt | awk '{print tolower($0)}' | tr -d ' ')/  | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep "http://www.youtube\|https://www.youtube" | sed 's/https:/http:/g' | sort | uniq | sort -R )" 
 				if [ "$playlist" ]; then
  					flite -t "Playing youtube link from R slash $(cat stt.txt)" 
					#printf $playlist
					playsong="$(printf $playlist | head -1)"
					#echo $playsong
					playfile="$(youtube-dl -x --get-filename $playsong)"
					#echo $playfile
					youtube-dl -x -w "$playsong"
					vlc <<<  "$playfile" 
				else
					flite -t "No links found"
				fi
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
