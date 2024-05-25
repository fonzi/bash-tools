#!/bin/bash

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null
then
    echo "ffmpeg could not be found, installing..."
    sudo apt-get update && sudo apt-get install -y ffmpeg
fi

# Directory to save audio captures
SAVE_DIR="$HOME/audio_captures"
mkdir -p "$SAVE_DIR"

# Duration of the capture in seconds (default 10 seconds)
DURATION=${1:-10}

# Function to capture audio from a given device
capture_audio() {
    local device=$1
    local filename="$SAVE_DIR/audio_capture_${device}_$(date +%Y%m%d_%H%M%S).wav"
    echo "Starting audio capture for $DURATION seconds on device $device..."
    ffmpeg -t "$DURATION" -f alsa -i "$device" "$filename"
    echo "Audio saved to $filename"
}

# Detect all audio input devices using arecord
echo "Detecting audio input devices..."
audio_devices=$(arecord -l | grep '^card' | awk '{print $2,$5}' | sed 's/://g' | sed 's/^/hw:/')

if [ -z "$audio_devices" ]; then
    echo "No audio input devices found."
    exit 1
fi

echo "Found the following audio input devices:"
echo "$audio_devices"

# Capture audio from each device
for device in $audio_devices; do
    capture_audio "$device"
done

