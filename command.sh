#!/bin/bash

function sayit() {
amixer set Capture toggle 2>&1 > /dev/null
flite -t "$say"
amixer set Capture toggle 2>&1 > /dev/null
}

function listen() {
# :p
rm speech
mkfifo speech
julius -quiet -input mic -C sample.jconf | tee -a speech 2>&1 > /dev/null
}

function detectname() {
if [ "$command" != "" ]; then
	#If $command with $name stripped doesn't equal $command then...
	if [ ! "${command#$name}" == "$command" ]; then
		namesaid="true"
		command="${command#$name }"
		#echo "Heard my name. Setting name flag and processing \"$command\""
		namesaid="true"
	fi
fi
}


#set -x 

#dep checks
if [ ! $(which julius) ]; then
	echo "You need julius. Install julius and julias-voxforge packages." 
	exit 1
fi
if [ ! $(which flite) ]; then
	echo "You need flite. Install flite package." 
	exit 1
fi


name="JORDAN"

#throw julius in the background writing to a fifo and let settle
listen &
sleep 1

#read from the fifo and process as soon as possible without blocking.
cat speech | while true; do 
	read rawcommand
	command=$(echo $rawcommand | grep sentence1: | sed -e 's/sentence1: <s> \(.*\) <\/s>/\1/')
	detectname
	#echo "$command"	
	case $command in
		"PLAY MUSIC")
			if [ "$namesaid" == "true" ]; then
				#echo "Playing music!"
				say="What would you like me to play?" 
				sayit
				lastcommand="$command"
				namesaid="false"
			else
				#echo "Need to hear my name to play music"
				lastcommand=""
			fi
			;;
		"STOP MUSIC")
			if [ "$namesaid" == "true" ]; then
				say="Killing VLC instances"
				sayit
				pkill vlc
			else
				#echo "Need to hear my name to stop music"
				lastcommand=""
			fi
			;;
		"WHAT TIME")
 			say="The time is $(date "+%l:%M %p")."
			sayit
			;;
		"WHAT DAY")
			say="Today is $(date "+%A %B %e")"
			sayit
			;;
		"WHAT UP")
			say="Not much. Whats up with you?"
			sayit
			;;
		"GO UP")
			say="Going up"
			sayit
			;;
		"GO DOWN")
			say="Going down"
			sayit
			;;
		"GO LEFT")
			say="Going left"
			sayit
			;;
		"GO RIGHT")
			say="Going right"
			sayit
			;;
		"COM PU TER")
			say="My name is $name"
			sayit
			;;
		"$name")
			let "resp = $RANDOM % 5 +1"
			case $resp in
				1) say="What?" ;;
				2) say="Yes?" ;;
				3) say="sir!" ;;
				4) say="Can I help you?" ;;
				5) say="Need something?" ;;
			esac
			sayit	
			lastcommand="$command"
			;;
			
		*)
			case $lastcommand in
				"PLAY MUSIC")
					say="searching"
					sayit
					#google_speech
					#./playsome.sh "$query"
					nohup vlc "http://www.youtube.com/watch?v=oHg5SJYRHA0" 2&>1 > /dev/null &
					lastcommand=""
					;;
				*)
					#lastcommand=""
					;;
			esac				
			;;
	esac
done;
