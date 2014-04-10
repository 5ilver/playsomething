#!/bin/bash
function listen() {
adintool -quiet -in mic -out file -filename file -oneshot
}
which ffmpeg && encoder="ffmpeg"
which avconv && encoder="avconv"
if [ "$encoder" == "" ];then
	echo "You need a flac encoder. Install ffmpeg or libav-tools (avconv)"
	exit 1
fi;
while listen; do 
ACTION=`julius -quiet -input rawfile -filelist files -C sample.jconf | grep sentence1: | sed -e 's/sentence1: <s> \(.*\) <\/s>/\1/'`
case $ACTION in
"COMP PLAY")
  echo "clicking"
  aplay beep.wav
  listen
  rm file.flac  > /dev/null 2>&1
  $encoder -i file.wav -ar 16000 -acodec flac file.flac
  wget -q -U "Mozilla/5.0" --post-file file.flac --header "Content-Type: audio/x-flac; rate=16000" -O - "http://www.google.com/speech-api/v1/recognize?lang=en-us&client=chromium" | cut -d\" -f12  >stt.txt
  vlc $(curl http://www.reddit.com/r/$(cat stt.txt | awk '{print tolower($0)}' | tr -d ' ')/  | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep "http://www.youtube\|https://www.youtube" | sed 's/https:/http:/g' ) &
  ;;
"COMP STOP")
  pkill vlc
  ;;
*)
  echo "wtf..."
  ;;
esac
done;
