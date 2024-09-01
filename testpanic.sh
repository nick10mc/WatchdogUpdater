#!/bin/bash
# Kernel Panic Test
# To be used for testing the Watchdog Timer
# By Nick McCatherine, Aug/31/2024
# Ohio State University
# Tested Aug/31/2024

##### WARNING, this script should ONLY be used to test the watchdog timer
# Requires permission to run
confFile="/etc/systemd/system.conf"

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
sudo su - <<EOF
whoami
# Lets make some popcorn
sudo echo 1 > /proc/sys/kernel/sysrq
sudo echo c > /proc/sysrq-trigger
whoami

EOF

sleep 5
exit


