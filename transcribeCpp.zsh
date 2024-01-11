#!/bin/zsh

# # First time only:
# # Clone repo

# cd into the cloned whisper.cpp repo
cd ~/whisper.cpp

# # First time only (or if you want to download a new model or have updated the source code):
# # Download small English model (see whisper.cpp README for the size of each model):
# bash ./models/download-ggml-model.sh small.en
# make

# Ask for file name
vared -p "Enter m4a or mp4 file name (without extension): " -c var1

folder1=~/Downloads/"Temp save/Audio to transcribe"
# # Ask for file location
# vared -p "Is it in the '.../Temp save/Audio to transcribe' folder? (y/n): " -c answer
# if [[ $answer != 'y' ]]; then
#     vared -p "Provide the full path to the folder it's in: " -c folder1
# else
#     folder1=~/Downloads/"Temp save/Audio to transcribe"
# fi

# Convert .mp4 or .m4a into a 16-bit .wav (required for whisper.cpp rn) 
if [[ -f "$folder1/$var1.mp4" ]]; then
    ffmpeg -i "$folder1/$var1.mp4" -ar 16000 -ac 1 -c:a pcm_s16le "$folder1/$var1.wav"
else
    ffmpeg -i "$folder1/$var1.m4a" -ar 16000 -ac 1 -c:a pcm_s16le "$folder1/$var1.wav"
fi

printf "\n\n\n"

# Transcribe .wav into a .txt file.
./main --file "$folder1/$var1.wav" --model ~/whisper.cpp/models/ggml-small.en.bin \
--no-timestamps --print-colors --print-progress --output-txt --output-srt --output-file "$folder1/$var1"

# Text editing
tr -d '\n' < "$folder1/$var1.txt" | awk '{gsub(/^ /, ""); gsub(/, okay\?/,"."); gsub(/Okay[?.] /,"");\
gsub(/Now,/,"\n\n---------\n\nNow,"); gsub(/So\b/,"\n\nSo")}1' | sponge "$folder1/$var1.txt"

awk '{gsub(/\. /,". \n"); gsub(/\? /,"? \n")}1' "$folder1/$var1.txt" > "$folder1/$var1 newlines.txt"