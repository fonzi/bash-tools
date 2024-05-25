#!/bin/bash

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null
then
    echo "ffmpeg could not be found, installing..."
    sudo apt-get update && sudo apt-get install -y ffmpeg
fi

# Check if v4l2-ctl is installed
if ! command -v v4l2-ctl &> /dev/null
then
    echo "v4l2-ctl could not be found, installing..."
    sudo apt-get update && sudo apt-get install -y v4l-utils
fi

# Directory to save video captures
SAVE_DIR="$HOME/webcam_captures"
mkdir -p "$SAVE_DIR"

# Duration of each capture in seconds (default 10 seconds)
CHUNK_DURATION=10

# Total duration for which the webcam should stay on (default 60 seconds)
TOTAL_DURATION=${1:-60}

# Function to capture video from a given webcam
capture_video() {
    local device=$1
    local chunk_duration=$2
    local filename="$SAVE_DIR/webcam_capture_$(basename "$device")_$(date +%Y%m%d_%H%M%S).mp4"
    echo "Starting webcam capture for $chunk_duration seconds on device $device..."
    ffmpeg -t "$chunk_duration" -f v4l2 -i "$device" -loglevel quiet "$filename"
    echo "Video saved to $filename"
}

# Detect all video devices
echo "Detecting video devices..."
video_devices=$(v4l2-ctl --list-devices | grep -E '/dev/video[0-9]+' -o)
if [ -z "$video_devices" ]; then
    echo "No video devices found."
    exit 1
fi

echo "Found the following video devices:"
echo "$video_devices"

# Calculate the number of chunks needed to cover the total duration
num_chunks=$((TOTAL_DURATION / CHUNK_DURATION))

# Capture video for the total duration, split into chunks
for ((i=0; i<num_chunks; i++)); do
    for device in $video_devices; do
        capture_video "$device" $CHUNK_DURATION
    done
    # Optional: Adjust sleep time if you want a slight pause between chunks
    sleep 1
done

echo "Finished capturing video for the total duration of $TOTAL_DURATION seconds."

