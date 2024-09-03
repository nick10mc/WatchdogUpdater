#!/bin/bash
# Kernel Panic Test
# To be used for testing the Watchdog Timer
# By Nick McCatherine, Aug/31/2024
# Ohio State University
# Tested Aug/31/2024

##### WARNING, this script should ONLY be used to test the watchdog timer
# Requires permission to run
if [ ! -x "$0" ]; then
    sudo chmod +x "$0"
fi


W="\033[1;37m" # White
R="\033[1;31m" # Red


echo -e "\n
\n${R}******************************
\n${W}WATCHDOG TESTER - KERNEL PANIC
\n******************************
\nUsage: Induces a kernel panic, used for testing the Watchdog settings
\n${R}WARNING: This script will crash the kernel! Save and close all documents prior to proceeding!
\n**DELETE THIS FILE AFTER CONFIRMING WDT OPERATION**
"                                                                                                                
confFile="/etc/systemd/system.conf"

## Ask user if they are sure about roasting their kernels
echo -e "\n${W}Are you sure you want to crash the system? \nY/N?"
read -r CONFIRM

if [ "$CONFIRM" != "Y" ] && [ "$CONFIRM" != "y" ]
then
    echo -e "\n${W}Kernel Panic Aborted"
    
else
    echo -e "\n${R}Kernel Panic Confirmed..."
    # Set confFile location
    confFile="/etc/systemd/system.conf"

    ## Check if the lines already exist
    ## Check the Runtime Watchdog first
    <<'EOF'
    if grep -q "^RuntimeWatchdogSec=" "$confFile"
    then
        # Lines exist, replace them
        sudo sed -i "s/^RuntimeWatchdogSec=.*/RuntimeWatchdogSec=$WDRUN_SEC/" "$confFile"
    else
        ## Append the following to the file:
        sudo echo -e "RuntimeWatchdogSec=$WDRUN_SEC" >> "$confFile"
    fi

    ## Now, check the Reboot Watchdog
    if grep -q "^RebootWatchdogSec=" "$confFile"
    then
        sudo sed -i "s/^RebootWatchdogSec=.*/RebootWatchdogSec=$WDREBT_SEC/" "$confFile"
    else
        ## Append the following to the file:
        sudo echo "RebootWatchdogSec=$WDREBT_SEC" >> "$confFile"
    fi

    echo -e "\n\t${G}Watchdog Enabled!"
EOF

    # Set countdown time to kernel panic
    countdown=10

    # Loop until the countdown reaches zero, then fire up the microwave
    while [ $countdown -gt 0 ]; do
        # -ne clears the terminal line when the cursor is \r returned to the beginning of the line
        echo -ne "${W}Time remaining to Panic: ${R}$countdown seconds\r"
    
        # Decrement the countdown
        ((countdown--))
    
        # Wait for 1 second
        sleep 1
    done

    # Check if watchdog timer is enabled
    if ! grep -q "^RuntimeWatchdogSec=" "$confFile"
    then
        echo "RuntimeWatchdogSec not set!"
        sleep 5
        exit
    fi

    ## Now, check the Reboot Watchdog
    if ! grep -q "^RebootWatchdogSec=" "$confFile"
    then
        echo "RebootWatchdogSec not set!"
        sleep 5
        exit
    fi

    # Run the following commands as root
    sudo su - <<'EOF'
    whoami
    # Lets make some popcorn
    sudo echo 1 > /proc/sys/kernel/sysrq
    sudo echo c > /proc/sysrq-trigger
    whoami

EOF

    # Print a final message
    echo -e "\nKernels roasted...\nIf you can read this, something is wrong with the set permission levels!"

fi

sleep 5
exit
