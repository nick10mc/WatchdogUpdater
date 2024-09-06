#!/bin/bash
## This is a shell script to install the Watchdog Timer Updater on all Raspberry Pis post Pi2B
## Nicholas McCatherine, Sept. 2, 2024, Ohio State Univeristy, EarthSci UnderGrad Research


##### Make sure to set execution permissions using 'sudo chmod a+x watchdog.sh'
if [ ! -x "$0" ]; then
    sudo chmod +x "$0"
fi

#set -x

W="\033[1;37m" # White
R="\033[1;31m" # Red

echo -e "\nInstalling WatchdogUpdater..."

DIR_="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo -e "\nDirectory set as $DIR_..."

WDTfile="watchdog.sh"
KERfile="testpanic.sh"
DELfile="delTest.sh"
acct=$USER
echo -e "\nAccount is $acct..."

# Check if files exist before moving them
if [[ ! -f "$WDTfile" ]]; then
    echo -e "${R}Error: ${W}File '$WDTfile' not found."
fi
if [[ ! -f "$KERfile" ]]; then
    echo -e "${R}Error: ${W}File '$KERfile' not found."
fi
if [[ ! -f "$DELfile" ]]; then
    echo -e "${R}Error: ${W}File '$DELfile' not found."
fi

# Set file permissions
echo -e '\nSetting file permissions'
sudo chmod 755 "/usr/local/bin/watchdog"
sudo chmod 755 "/home/$acct/Desktop/testpanic"
sudo chmod 555 "/home/$acct/Desktop/DeleteTestPanic"

# Lets transfer our files as root
echo -e '\nTransfering files as the root user...'
sudo mv -u "$WDTfile" "/usr/local/bin/watchdog"
sudo mv -u "$KERfile" "/home/$acct/Desktop/testpanic"
sudo mv -u "$DELfile" "/home/$acct/Desktop/DeleteTestPanic"
# Install the "load based" watchdog
echo -e '\nInstalling the "Load Based" watchdog software package...'
sudo apt-get update || { echo 'apt update failed'; }
sleep 1
sudo apt-get upgrade -y || { echo 'apt upgrade failed'; }
sleep 1
sudo apt-get install -y watchdog || { echo 'Failed to install watchdog'; }

# Remove installation directory and files, cleanup
echo -e "\nCleaning up install files. 'testpanic' installed on desktop. 
${R}**IMPORTANT** ${W}Use ${R}'shred -u /home/$USER/Desktop/testpanic' 
${W}after testing the Watchdog, or use the 'DeleteTestPanic' script on the desktop 
that was installed with the panic script."

cd ~/
sleep 30
#rm -rf "$DIR_"
exit 0