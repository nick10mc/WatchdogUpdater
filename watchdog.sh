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

##### Make sure to set execution permissions using 'chmod a+x watchdog.sh'
# chmod a+x "$0"


W="\033[1;37m" # White
R="\033[1;31m" # Red
G="\033[1;32m" #Green
B="\033[1;34m" # Blue

## Record the desired Watchdog periods
echo -e "${W}***Watchdog Enabler***"
echo -e "\t\tBy Nick McCatherine, August 8th, 2024"
echo -e "\n************************************************************************\n"
echo -e "Usage: The Watchdog Sampling Period defines the time the watchdog should wait until it reboots the Pi.\n"
echo -e "The Reboot Watchdog determines how long the Watchdog timer should wait for a reboot to complete before trying again.\n"
echo -e "\n\n ${R}Please input the desired Watchdog sampling period in seconds: \n" 
read -r WDRUN_SEC
echo -e "\n\t ${G}$WDRUN_SEC Confirmed!"
echo -e "\n\n ${R}Please input the desired reboot Watchdog sampling period in seconds: \n"
read -r WDREBT_SEC
echo -e "\n\t ${G}$WDREBT_SEC Confirmed!"

## Ask user if they are sure about updating the system.conf
echo -e "\n${W}Are you sure you want to enable the Watchdog with these variables? \nY/N?"
read -r CONFIRM

## Validate input and confirmation
if [ "$CONFIRM" != "Y" ] && [ "$CONFIRM" != "y" ]
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
