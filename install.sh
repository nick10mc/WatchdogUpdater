#!/bin/bash
## This is a shell script to install the Watchdog Timer Updater on all Raspberry Pis post Pi2B
## Nicholas McCatherine, Sept. 2, 2024, Ohio State Univeristy, EarthSci UnderGrad Research


##### Make sure to set execution permissions using 'sudo chmod a+x watchdog.sh'
if [ ! -x "$0" ]; then
    sudo chmod +x "$0"
fi

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
# Run following commands as root
export WDTfile KERfile acct DIR_
sudo -E bash -c "
    # Lets transfer our files as root
    echo -e '\nTransfering files as the root user...'
    mv -u "$WDTfile" "/usr/local/bin/watchdog"
    mv -u "$KERfile" "/home/$acct/Desktop/testpanic"
    mv -u "$DELfile" "/home/$acct/Desktop/DeleteTestPanic"

    # Set file permissions
    echo -e '\nSetting file permissions'
    chmod 755 "/usr/local/bin/watchdog"
    chmod 600 "/home/$acct/Desktop/testpanic"
    chmod 555 "/home/$acct/Desktop/DeleteTestPanic"
    whoami
"

# Remove installation directory and files, cleanup
echo -e "\nCleaning up install files. "testpanic" installed on desktop. 
${R}**IMPORTANT** ${W}Use ${R}'shred -u //home/$USER/Desktop/testpanic' 
${W}after testing the Watchdog, or use the 'DeleteTestPanic' script on the 
desktop that was installed with the panic script."
sleep 30
cd ~/
rm -rf "$DIR_"
