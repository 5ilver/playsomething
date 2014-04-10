#!/bin/bash
while true; do 
adintool -in mic -out file -filename file -oneshot
ACTION=`julius -quiet -input rawfile -filelist files -C sample.jconf | grep sentence1: | sed -e 's/sentence1: <s> \(.*\) <\/s>/\1/'`
case $ACTION in
"COMP PLAY")
  echo "clicking"
  aplay beep.wav
  adintool -in mic -out file -filename file -oneshot
  rm file.flac  > /dev/null 2>&1
  ffmpeg -i file.wav -ar 16000 -acodec flac file.flac
  wget -q -U "Mozilla/5.0" --post-file file.flac --header "Content-Type: audio/x-flac; rate=16000" -O - "http://www.google.com/speech-api/v1/recognize?lang=en-us&client=chromium" | cut -d\" -f12  >stt.txt
  playsome $(cat stt.txt | awk '{print tolower($0)}' | tr -d ' ') &
  ;;
"COMP STOP")
  pkill vlc
  ;;
*)
  echo "wtf..."
  ;;
esac
done;
