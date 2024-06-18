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
    local two_hours_before_sunrise=$((sunrise_hour - 2))
    sunrise_hour=$((10#$sunrise_hour))
    sunset_hour=$((10#$sunset_hour))

    echo "current hour:" $current_hour
    echo "sunrise hour:" $sunrise_hour
    echo "sunset hour:" $sunset_hour

    if [ "$current_hour" -ge "$sunrise_hour" ] && [ "$current_hour" -lt 12 ]; then
        # From sunrise to noon - maintain highest temperature
        temp=6500
    elif [ "$current_hour" -ge 12 ] && [ "$current_hour" -lt "$sunset_hour" ]; then
        # From noon to sunset - gradually decrease temperature
        temp=$((6500 - (current_hour - 12) * ((6500 - 2500) / (sunset_hour - 12))))
    elif [ "$current_hour" -ge "$sunset_hour" ] || [ "$current_hour" -lt "$two_hours_before_sunrise" ]; then
        # Evening and night until 2 hours before sunrise - maintain lowest temperature (2500K)
        temp=2500
    else
        # 2 hours before sunrise to sunrise - gradually increase temperature
        temp=$((2500 + (current_hour - two_hours_before_sunrise) * ((6500 - 2500) / (sunrise_hour - two_hours_before_sunrise))))
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

PAUSE="false"

# Function to display the About message with a slider and Quit option
show_about() {
    current_temp=$(xsct | grep -oP '(?<=temperature ~ )\d+')
    response=$(yad --scale --value=$current_temp --min-value=1000 --max-value=6500 --step=100 \
        --title="About Screen Temperature Adjuster" \
        --text="Created by Fonzi Vazquez\nLatitude: $LAT\nLongitude: $LNG\nhttps://fonzi.xyz\nGPL-3.0 license" \
        --button="Set:0" --button="Pause:1" --button="Resume:2" --button="Quit:3")
    
    res=$?
    if [ $res -eq 0 ]; then
        new_temp=$(echo "$response" | cut -d '|' -f 1)
        xsct $new_temp
    elif [ $res -eq 1 ]; then
        xsct 6500
        PAUSE="true"
        echo "pause"
    elif [ $res -eq 2 ]; then
        PAUSE="false"
        echo "unpause"
        set_screen_temp
    elif [ $res -eq 3 ]; then
        cleanup
    fi
}

# Export function and variables to make them available to subshells
export -f show_about cleanup set_screen_temp get_sun_times
export LAT
export LNG
export SUNRISE
export SUNSET
export PAUSE

# Start the YAD notification icon
yad --notification --text="Screen Temperature Adjuster" --image="dialog-information" --command="bash -c 'show_about'" &
YAD_PID=$!

# Run the script in an infinite loop, updating every hour
while true; do
    if [ "$PAUSE" != "true" ]; then
        set_screen_temp
    fi

    sleep 3600  # Sleep for 1 hour

    # Update sunrise and sunset times every 2 hours
    get_sun_times
done
