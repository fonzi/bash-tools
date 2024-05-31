#!/bin/bash

# Usage: session_manager.sh [path/to/your.ovpn]
#
# This script starts an OpenVPN connection using the provided .ovpn configuration file,
# displays a warning message while the VPN is connected, and provides a menu for managing
# the VPN session. It also shows a system tray icon indicating that the VPN is connected.
#
# Requirements:
# - openvpn3
# - yad (for the system tray icon)
#
# Installation of requirements:
# sudo apt-get install openvpn3 yad
#
# If the .ovpn file path is not provided as a command-line argument, the script will prompt for it.
#
# Menu Options:
# 1) Show current sessions - Displays the current OpenVPN sessions.
# 2) Show available configurations - Lists available OpenVPN configurations.
# 3) Exit - Stops the OpenVPN connection and exits the script.
#
# Example usage:
# ./session_manager.sh /path/to/your.ovpn
# ./session_manager.sh (will prompt for the .ovpn file path)

# Function to handle Ctrl+C and exit
cleanup() {
    echo -e "\nStopping OpenVPN connection..."
    openvpn3 session-manage --disconnect --config "$OVPN_PATH"
    echo "Connection stopped. Exiting..."
    pkill -f "yad --notification"  # Stop the system tray icon
    exit 0
}

# Trap Ctrl+C (SIGINT) and exit command to call cleanup
trap cleanup SIGINT

# Function to show menu options
show_menu() {
    clear
    echo -e "\033[0;31m👁 YOU ARE CONNECTED THEY CAN SEE YOU!! 👁\033[0m"
    echo -e "\033[0;31m👁 YOU ARE CONNECTED THEY CAN SEE YOU!! 👁\033[0m"
    echo -e "\033[0;31m👁 YOU ARE CONNECTED THEY CAN SEE YOU!! 👁\033[0m"
    echo -e "\033[0;32mMenu:\033[0m"
    echo -e "\033[0;32m1) Show current sessions\033[0m"
    echo -e "\033[0;32m2) Show available configurations\033[0m"
    echo -e "\033[0;31m3) Exit\033[0m"
}

# Check if the OVPN file path was provided as an argument
if [ -z "$1" ]; then
    read -p "Enter the path to the OVPN file: " OVPN_PATH
else
    OVPN_PATH=$1
fi

# Extract the file name from the OVPN path
OVPN_FILE_NAME=$(basename "$OVPN_PATH")

# Start OpenVPN connection
echo "Starting OpenVPN connection with configuration: $OVPN_PATH"
openvpn3 session-start --config "$OVPN_PATH" &

# PID of the OpenVPN process
VPN_PID=$!

# Wait for the OpenVPN process to complete
wait $VPN_PID

# Wait for a bit to ensure the browser opens
sleep 5

# Prompt the user to check if they have authenticated in the browser
while true; do
    read -p "Have you authenticated in the browser? (Y/N): " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        break
    else
        echo "Please authenticate in the browser and then answer 'Y' to continue."
    fi
done

# Function to start the system tray icon
start_tray_icon() {
    while :; do
        yad --notification --image=network-vpn --text "Connected: $OVPN_FILE_NAME" --no-middle --no-left
        sleep 1
    done
}

# Start the system tray icon in the background
start_tray_icon &

# Keep the script running until the user exits
while :; do
    show_menu
    read -p "Select an option: " input
    case $input in
        1)
            echo "Current OpenVPN sessions:"
            openvpn3 sessions-list
            ;;
        2)
            echo "Available OpenVPN configurations:"
            openvpn3 configs-list
            ;;
        3 | exit)
            cleanup
            ;;
        *)
            echo "Invalid option. Please select 1, 2, or 3."
            ;;
    esac
    read -p "Press Enter to continue..."
done

