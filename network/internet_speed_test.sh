#!/bin/bash

# ASCII art and introduction
cat << "EOF"
 

                            __...------------._
                         ,-'                   `-.
                      ,-'                         `.
                    ,'                            ,-`.
                   ;                              `-' `.
                  ;                                 .-. \
                 ;                           .-.    `-'  \
                ;                            `-'          \
               ;                                          `.
               ;                                           :
              ;                                            |
             ;                                             ;
            ;                            ___              ;
           ;                        ,-;-','.`.__          |
       _..;                      ,-' ;`,'.`,'.--`.        |
      ///;           ,-'   `. ,-'   ;` ;`,','_.--=:      /
     |'':          ,'        :     ;` ;,;,,-'_.-._`.   ,'
     '  :         ;_.-.      `.    :' ;;;'.ee.    \|  /
      \.'    _..-'/8o. `.     :    :! ' ':8888)   || /
       ||`-''    \\88o\ :     :    :! :  :`""'    ;;/
       ||         \"88o\;     `.    \ `. `.      ;,'
       /)   ___    `."'/(--.._ `.    `.`.  `-..-' ;--.
       \(.="""""==.. `'-'     `.|      `-`-..__.-' `. `.
        |          `"==.__      )                    )  ;
        |   ||           `"=== '                   .'  .'
        /\,,||||  | |           \                .'   .'
        | |||'|' |'|'           \|             .'   _.' \
        | |\' |  |           || ||           .'    .'    \
        ' | \ ' |'  .   ``-- `| ||         .'    .'       \
          '  |  ' |  .    ``-.._ |  ;    .'    .'          `.
       _.--,;`.       .  --  ...._,'   .'    .'              `.__
     ,'  ,';   `.     .   --..__..--'.'    .'                __/_\
   ,'   ; ;     |    .   --..__.._.'     .'                ,'     `.
  /    ; :     ;     .    -.. _.'     _.'                 /         `
 /     :  `-._ |    .    _.--'     _.'                   |
/       `.    `--....--''       _.'                      |
          `._              _..-'                         |
             `-..____...-''                              |
                                                         |
 

.__   __.  _______ .___________.    _______..______    _______  _______  _______  .___________..______          ___       ______  __  ___  _______ .______      
|  \ |  | |   ____||           |   /       ||   _  \  |   ____||   ____||       \ |           ||   _  \        /   \     /      ||  |/  / |   ____||   _  \     
|   \|  | |  |__   `---|  |----`  |   (----`|  |_)  | |  |__   |  |__   |  .--.  |`---|  |----`|  |_)  |      /  ^  \   |  ,----'|  '  /  |  |__   |  |_)  |    
|  . `  | |   __|      |  |        \   \    |   ___/  |   __|  |   __|  |  |  |  |    |  |     |      /      /  /_\  \  |  |     |    <   |   __|  |      /     
|  |\   | |  |____     |  |    .----)   |   |  |      |  |____ |  |____ |  '--'  |    |  |     |  |\  \----./  _____  \ |  `----.|  .  \  |  |____ |  |\  \----.
|__| \__| |_______|    |__|    |_______/    | _|      |_______||_______||_______/     |__|     | _| `._____/__/     \__\ \______||__|\__\ |_______|| _| `._____|
                                                                                                                                                                                              
Welcome to NetSpeedTracker!
                    - Fonzi
EOF

# File to store the results
LOGFILE="speedtest_results.log"

# Default sleep time
SLEEP_TIME=60

# Function to check internet connectivity
check_internet() {
    wget -q --spider http://google.com
    return $?
}

# Function to install required tools if not already installed
install_tools() {
    if ! command -v speedtest-cli &> /dev/null
    then
        echo "$(date "+%Y-%m-%d %H:%M:%S") speedtest-cli not found, installing..." | tee -a $LOGFILE
        sudo apt-get update | tee -a $LOGFILE
        sudo apt-get install -y speedtest-cli | tee -a $LOGFILE
        echo "$(date "+%Y-%m-%d %H:%M:%S") speedtest-cli installed successfully." | tee -a $LOGFILE
    else
        echo "$(date "+%Y-%m-%d %H:%M:%S") speedtest-cli is already installed." | tee -a $LOGFILE
    fi

    if ! command -v gnuplot &> /dev/null
    then
        echo "$(date "+%Y-%m-%d %H:%M:%S") gnuplot not found, installing..." | tee -a $LOGFILE
        sudo apt-get update | tee -a $LOGFILE
        sudo apt-get install -y gnuplot | tee -a $LOGFILE
        echo "$(date "+%Y-%m-%d %H:%M:%S") gnuplot installed successfully." | tee -a $LOGFILE
    else
        echo "$(date "+%Y-%m-%d %H:%M:%S") gnuplot is already installed." | tee -a $LOGFILE
    fi
}

# Function to perform the speed test and log results
perform_speedtest() {
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    SPEEDTEST_RESULT=$(speedtest-cli --simple)
    DOWNLOAD_SPEED=$(echo "$SPEEDTEST_RESULT" | grep "Download" | awk '{print $2}')
    UPLOAD_SPEED=$(echo "$SPEEDTEST_RESULT" | grep "Upload" | awk '{print $2}')
    PING=$(echo "$SPEEDTEST_RESULT" | grep "Ping" | awk '{print $2}')
    echo "$TIMESTAMP, $PING, $DOWNLOAD_SPEED, $UPLOAD_SPEED" >> $LOGFILE
}

# Function to generate the ASCII graph
generate_ascii_graph() {
    gnuplot <<-EOFMarker
        set title "Internet Speed Over Time"
        set xlabel "Time"
        set ylabel "Speed (Mbps)"
        set xdata time
        set timefmt "%Y-%m-%d %H:%M:%S"
        set format x "%H:%M"
        set terminal dumb
        plot "$LOGFILE" using 1:3 title 'Download Speed' with lines, \
             "$LOGFILE" using 1:4 title 'Upload Speed' with lines
EOFMarker
}

# Function to save graph as an image
save_graph_as_image() {
    gnuplot <<-EOFMarker
        set title "Internet Speed Over Time"
        set xlabel "Time"
        set ylabel "Speed (Mbps)"
        set xdata time
        set timefmt "%Y-%m-%d %H:%M:%S"
        set format x "%H:%M"
        set terminal png
        set output 'internet_speed_over_time.png'
        plot "$LOGFILE" using 1:3 title 'Download Speed' with lines, \
             "$LOGFILE" using 1:4 title 'Upload Speed' with lines
EOFMarker
}

# Function to get active network interface
get_active_interface() {
    default_interface=$(ip route | grep '^default' | awk '{print $5}')
    if [ -z "$default_interface" ]; then
        echo "No active network interface found."
        exit 1
    fi
    echo "Active network interface: $default_interface"
    export INTERFACE=$default_interface
}

# Install required tools
install_tools

# Get active network interface
get_active_interface

# Get optional sleep time from user
echo "Enter the sleep time in seconds between tests (default is 60 seconds):"
read user_input
if [[ ! -z "$user_input" && "$user_input" =~ ^[0-9]+$ ]]; then
    SLEEP_TIME=$user_input
fi

# Ask if user wants to save the graph as an image
echo "Do you want to save the graph as an image? (y/n)"
read save_image

# Spinner function
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Infinite loop to perform speed test every defined interval
while true; do
    if check_internet; then
        perform_speedtest &
        SPID=$!
        spinner $SPID
        wait $SPID
        clear
        generate_ascii_graph
        if [[ "$save_image" == "y" || "$save_image" == "Y" ]]; then
            save_graph_as_image
        fi
    else
        echo "$(date "+%Y-%m-%d %H:%M:%S"), No internet connection" | tee -a $LOGFILE
    fi
    # ASCII animation
    for i in {1..10}; do
        echo -ne "Running test. Please wait $(printf '%.0s.' $(seq 1 $i))\r"
        sleep $((SLEEP_TIME / 10))
    done
    echo -ne "\n"
done

