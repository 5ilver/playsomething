#!/bin/bash
while true; do 
adintool -in mic -out file -filename file -oneshot
ACTION=`julius -quiet -input rawfile -filelist files -C sample.jconf | grep sentence1: | sed -e 's/sentence1: <s> \(.*\) <\/s>/\1/'`
case $ACTION in
"COMP PLAY")
  echo "clicking"
  aplay beep.wav
  adintool -in mic -out file -filename file -oneshot
  ./gspeech.sh
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
