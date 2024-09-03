#!/bin/bash
## This is a shell script to install the Watchdog Timer Updater on all Raspberry Pis post Pi2B
## Nicholas McCatherine, Sept. 2, 2024, Ohio State Univeristy, EarthSci UnderGrad Research


##### Make sure to set execution permissions using 'sudo chmod a+x watchdog.sh'
if [ ! -x "$0" ]; then
    sudo chmod +x "$0"
fi

W="\033[1;37m" # White
R="\033[1;31m" # Red

KERfile="testpanic"
DELfile="DeleteTestPanic"
acct=$USER
echo -e "\nAccount is $acct..."
# Run following commands as root
export WDTfile KERfile acct DIR_
sudo -E bash -c "
    # Delete the Kernel Panic test script
    echo -e '\nDeleting the Watchdog Kernel Panic Test Script...'
    shred -u "//home/$USER/Desktop/testpanic"
    whoami
"

# Remove the DeleteTestPanic file
echo -e "\nDeleting this script in 10s..."
rm $0
sleep 10
exit