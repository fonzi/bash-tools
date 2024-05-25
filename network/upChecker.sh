#!/bin/bash

# Check if a URL is online and wait for it to become available
# Usage: ./check_website.sh <URL>

url=$1
tries=0
max_tries=50

while [ $tries -lt $max_tries ]; do
    status_code=$(curl --silent --output /dev/null --head --write-out '%{http_code}\n' "$url")
    if [ $status_code -eq 200 ]; then
        echo "$url is online"
        exit 0
    else
        echo "$url is offline (status code: $status_code)"
        tries=$((tries+1))
        sleep 1
    fi
done

echo "Maximum number of tries ($max_tries) reached, $url is still offline"
exit 1
