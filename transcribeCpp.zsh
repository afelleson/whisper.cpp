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
--no-timestamps --print-colors --print-progress --output-txt --output-file "$folder1/$var1"

# Remove newlines and separate sentences by newlines (.txt) or bullets (.rtf)
tr -d '\n' < "$folder1/$var1.txt" | awk '{gsub(/\. /,". \n"); gsub(/\? /,"? \n")}1' \
| awk '{gsub(/, okay?/,"."); gsub(/Okay? /,""); gsub(/Now,/,"\nNow,")}1' > "$folder1/$var1 newlines.txt"

# Delete the original .txt file
# rm input.txt

# Note: The quotation marks around path names aren't always necessary. 
# I like them because they make it easier to spot the paths. 
# They're useful for paths that have spaces in them, but there are other ways to deal with those too. 
# If folder1 or var1 might have spaces, it's a good idea to include the quotes.

# Save this file as transcribeCpp.zsh
# Then run the following to make this script executable (only have to do this once, not every time you edit this file):
#     chmod +x transcribeCpp.zsh 
# Run this script via 
#     ./transcribeCpp.zsh