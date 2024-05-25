#!/bin/bash

# Log file
LATENCY_LOG="network_latency.log"

# Servers to ping
SERVERS=("8.8.8.8" "1.1.1.1" "google.com")

# Function to log latency
log_latency() {
    echo "Logging network latency..."
    for server in "${SERVERS[@]}"; do
        latency=$(ping -c 4 $server | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
        if [ -n "$latency" ]; then
            log_entry="$(date '+%Y-%m-%d %H:%M:%S') - $server: $latency ms"
            echo "$log_entry" | tee -a $LATENCY_LOG
        else
            log_entry="$(date '+%Y-%m-%d %H:%M:%S') - $server: No response"
            echo "$log_entry" | tee -a $LATENCY_LOG
        fi
    done
}

# Start logging latency
log_latency

exit 0
