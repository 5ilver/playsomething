#!/bin/bash
rm file.flac  > /dev/null 2>&1
ffmpeg -i file.wav -ar 16000 -acodec flac file.flac
wget -q -U "Mozilla/5.0" --post-file file.flac --header "Content-Type: audio/x-flac; rate=16000" -O - "http://www.google.com/speech-api/v1/recognize?lang=en-us&client=chromium" | cut -d\" -f12  >stt.txt
echo
echo
echo
cat stt.txt
echo
echo
echo
rm file.flac  > /dev/null 2>&1
