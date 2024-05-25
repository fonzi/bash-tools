#!/bin/bash

# Network Interface Status Check
check_interfaces() {
    echo "Checking network interfaces status..."
    ip link show | grep -E "^[0-9]+:" | while read -r line; do
        iface=$(echo "$line" | awk -F: '{print $2}' | xargs)
        status=$(echo "$line" | grep -o "state [A-Z]*" | awk '{print $2}')
        echo "Interface: $iface is $status"
    done
}

check_interfaces
