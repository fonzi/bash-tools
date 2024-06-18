#!/bin/bash

# Define the location for sunrise and sunset calculations
LAT="43.547"
LNG="-96.728"
API_URL="https://api.sunrise-sunset.org/json?lat=$LAT&lng=$LNG&formatted=0"

# Function to get sunrise and sunset times and convert to local time
get_sun_times() {
	echo "url:" $API_URL
    response=$(curl -s "$API_URL")
    SUNRISE_UTC=$(echo $response | jq -r '.results.sunrise')
    SUNSET_UTC=$(echo $response | jq -r '.results.sunset')
    SUNRISE=$(date -d "$SUNRISE_UTC" +%H:%M)
    SUNSET=$(date -d "$SUNSET_UTC" +%H:%M)
}

set_screen_temp() {
    local current_hour=$(date +%H)
    current_hour=$((10#$current_hour))  # Convert to decimal to avoid octal interpretation

    # Convert SUNRISE and SUNSET to hours
    local sunrise_hour=$(date -d "$SUNRISE" +%H)
    local sunset_hour=$(date -d "$SUNSET" +%H)
    sunrise_hour=$((10#$sunrise_hour))
    sunset_hour=$((10#$sunset_hour))

    echo "current hour:" $current_hour
    echo "sunrise hour:" $sunrise_hour
    echo "sunset hour:" $sunset_hour

    if [ "$current_hour" -ge "$sunrise_hour" ] && [ "$current_hour" -lt 12 ]; then
        # From sunrise to noon - highest temperature
        temp=6500
    elif [ "$current_hour" -ge 12 ] && [ "$current_hour" -lt "$sunset_hour" ]; then
        # Afternoon - gradually decrease temperature
        temp=$((6500 - (current_hour - 12) * 500))
    else
        # Evening and night - lowest temperature
        temp=1000
    fi
    xsct $temp
    echo "set temperature to:" $temp
}
# Function to handle cleanup on exit
cleanup() {
    xsct 6500  # Reset screen temperature to 6500
    if [ -n "$YAD_PID" ]; then
        kill $YAD_PID
    fi
    exit 0
}

# Trap SIGINT (Ctrl+C) and SIGTERM to clean up
trap cleanup SIGINT SIGTERM

# Initial fetch of sunrise and sunset times
get_sun_times

# Function to display the About message with a slider
show_about() {
    current_temp=$(xsct | grep -oP '(?<=temperature ~ )\d+')
    new_temp=$(yad --scale --value=$current_temp --min-value=1000 --max-value=6500 --step=100 \
                   --title="About Screen Temperature Adjuster" \
                   --text="Created by Fonzi Vazquez\nLatitude: $LAT\nLongitude: $LNG\nhttps://fonzi.xyz\n GPL-3.0 license")
    if [ $? -eq 0 ]; then
        xsct $new_temp
    fi
}

# Export function and variables to make them available to subshells
export -f show_about
export LAT
export LNG
export SUNRISE
export SUNSET

# Start the YAD notification icon
yad --notification --text="Screen Temperature Adjuster" --image="dialog-information" --command="bash -c 'show_about'" &
YAD_PID=$!

# Run the script in an infinite loop, updating every 2 hours
while true; do
    set_screen_temp

    sleep 3600  # Sleep for 2 hours

    # Update sunrise and sunset times every 2 hours
    get_sun_times
done
