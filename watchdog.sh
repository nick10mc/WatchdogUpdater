#!/bin/bash
## This is a shell script to update the system configuration file to use the hardware
## Watchdog Timer on all Raspberry Pis post Pi2B
## Nicholas McCatherine, Aug. 8, 2024, Ohio State Univeristy, EarthSci UnderGrad Research
## Updated Aug/31/2024
## Tested Aug/31/2024
##      More tests required to determine exact installation procedure. It works, but I didn't record what I did. Probably needs to be in an executable directory

## Changelog Aug. 31 2024
# Made $CONFIRM case insensitive
# Added sudo to sed and certain echo commands
# Added ability to restart the systemctl daemon so that the changes are effective immediately without rebooting

##### Make sure to set execution permissions using 'sudo chmod a+x watchdog.sh'
if [ ! -x "$0" ]; then
    sudo chmod +x "$0"
fi

convertToSec() {
    local time=$1
    
    if [[ $time =~ ^[0-9]+s$ ]]; 
    then
        # Time is already in seconds
        echo "${time%s}"
    elif [[ $time =~ ^[0-9]+min$ ]]; then
        # Time is in minutes, convert to seconds
        local minutes="${time%min}"
        echo $((minutes * 60))
    else
        echo "Invalid time format: $time" >&2
        exit 1
    fi
}

abs() {
    local value=$1

    # Check if the value is negative
    if [ "$value" -lt 0 ]; 
    then
        # Multiply by -1 to make it positive
        value=$(( value * -1 ))
    fi

    echo "$value"
}

W="\033[1;37m" # White
R="\033[1;31m" # Red
G="\033[1;32m" #Green
B="\033[1;34m" # Blue

#############################################################################
## Record the desired Watchdog periods
echo -e "${W}***Watchdog Enabler***"
echo -e "\t\tBy Nick McCatherine, August 8th, 2024"
echo -e "\n************************************************************************\n"
echo -e "Usage: The Watchdog Sampling Period defines the time the watchdog should wait until it reboots the Pi.\n"
echo -e "The Reboot Watchdog determines how long the Watchdog timer should wait for a reboot to complete before trying again.\n"

echo -e "\n\n ${R}Please input the desired Watchdog sampling period: \n" 
read -r WDRUN
WDRUN_SEC=$(convertToSec "$(abs "$WDRUN")")
# Check if WDRUN_SEC is less than or equal to 0
if [ "$WDRUN_SEC" -le 0 ]
then
    echo -e "\n${R}ERROR: Input Watchdog sampling period is or less than zero!"
    sleep 10
    exit
else
    echo -e "\n\t ${G}$WDRUN_SEC Confirmed!"
fi


echo -e "\n\n ${R}Please input the desired reboot Watchdog sampling period (15s minimum difference): \n"
read -r WDREBT
WDREBT_SEC=$(convertToSec "$(abs "$WDREBT")")
# Check if REBT_SEC is less than WDRUN_SEC + 15s
if [ "$WDREBT_SEC" -lt $((WDRUN_SEC+15)) ]
then
    echo -e "\n${R}ERROR: Input Reboot sampling period is less than the Watchdog sampling period plus 15 seconds!"
    sleep 10
    exit
elif [ "$WDREBT_SEC" -eq 0 ]
    echo -e "\n${R}ERROR: Input Reboot sampling period is zero!"
    sleep 10
    exit
else
    echo -e "\n\t ${G}$WDREBT_SEC Confirmed!"
fi


## Ask user if they are sure about updating the system.conf
echo -e "\n${W}Are you sure you want to enable the Watchdog with these variables? \nY/N?"
read -r CONFIRM

## Validate input and confirmation
if [[ "$CONFIRM" != "Y" && "$CONFIRM" != "y" ]]
then
    echo -e "\n${R}Watchdog Not Enabled, Cancelled"
    
else
    echo -e "\n${B}Updating /etc/systemd/system.conf"
    # Set file location
    confFile="/etc/systemd/system.conf"

    ## Check if the lines already exist
    ## Check the Runtime Watchdog first
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
fi

# Restart the systemctl daemon without rebooting
echo -e "\n\t${B}Restarting ${W}systemctl ${B}daemon..."
sudo systemctl daemon-reload
echo -e "\n\t${G}Done!"

echo -e "\n${W}Shell will close automatically in 10s"
sleep 10
exit

