# WatchdogUpdater
## Watchdog timer updater primarily for Raspberry Pis. This script allows for the easy mass-deployment of a Watchdog timer to devices and applications that currently do not use one.

*By Nick McCatherine, Ohio State University,
August 31st, 2024.*

### Downloading:
To download the WatchdogUpdater, you must obtain access permission via your Github account, or copy the authorization token provided to you.
You must then execute the following in a terminal[^1]:
```
sudo apt update
sudo apt install gh -y
gh auth login
```
*Not knowing the requirements of the University to release this publicly due to it being a part of my undergraduate research, authorization is required to access this repository*

### Installation:
To install the WatchdogUpdater once authorized, execute these commands:
```
gh repo clone WatchdogUpdater
sudo chmod +x "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/WatchdogUpdater/install.sh"
"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/WatchdogUpdater/install.sh"
```
### Usage: 
1. Open a terminal, and type in the following: watchdog
2. Set your preffered Watchdog timer period. ("5" recommended)
3. Set your reboot Watchdog timer period. This should be significantly longer than the Watchdog timer ("1min" recommended)
4. Set the software-based Watchdog[^2] settings. This watchdog timer is primarily concerned with the average load over a set period of time.
5. Confirm your settings
6. Done! You can check to see if it was indeed updated by opening the system.conf file in /etc/systemd/
7. Perform a test to double check the function of the timer in a safe environment, read ahead...

### Real world testing:
To test the watchdog, the easiest and most foolproof method is not to use a fork bomb (*due to limits in the OS designed to prevent this*), but to trigger a kernel panic. A script is provided in this repository to do just that.
Simply go to the Desktop, and execute the file named "testpanic". The script will ask you to confirm if you want to test the Watchdog timer in this manner.
After asking for confirmation, it will check the system.conf file to see if the requisite fields are filled and will report if they are not. If the kernel panic is not triggered,
the script will print a line stating such, with the most likely reason being that the file does not have the requisite permission to execute.

### Finishing up:
The Watchdog timer can be updated at any time by using the "watchdog" command. Only numerical values that are not zero are accepted.
A reboot is not required but recommended, as the systemctl daemon is automatically restarted when "watchdog" is executed, and it should update the timer when it reboots.
> [!CAUTION]
> It is reccommended that the "testpanic.sh" script be shredded before proceeding to use this in any application outside of a test environment. This can be done with the script named **"DeleteTestPanic"** that was placed on the Desktop.




### More information: 
> [!Note]
This script sets two fields in the system.conf file: RuntimeWatchdogSec and RebootWatchdogSec. In short, the Watchdog timer is a register and counter pair embedded within the CPU along with some glue logic and a digital comparator. The operation of the timer is simple: A set value is stored in the register, which is set by the "xWatchdogSec" fields in system.conf. This value sets the maximum number that the counter is allowed to count up to in binary and applies it to one input of the digital comparator. As power is applied to the CPU, the counter will increment up one unit until the binary value surpasses the maximal binary number set in the comparator and if it exceeds that value, a flag or "signal" is sent to the neccessary hardware to reboot the CPU and its accompanying hardware. To prevent a reboot by the Watchdog timer, the CPU will periodically send a "heartbeat" signal to the Watchdog counter, which resets the count value to 0, thus restarting the Watchdog period. If the CPU is frozen, it will be unable to send this heartbeat signal. The incrementation of the counter is, in many cases, controlled directly by the clock signal produced by an onboard oscillator, typically the same used to provide the base clock for the CPU. It is possible for other subsystems to, themselves, have watchdog timers (IE: a WiFi chipset).

> [!Tip]
The "RuntimeWatchdog" monitors the normal operation of the CPU, while the "RebootWatchdog" monitors the CPU during startup. The "RebootWatchdog" requires a longer time period due to the fact that the CPU may not have enough time to reboot to reset the main "RuntimeWatchdog" timer.
>
> [^1]:https://github.com/cli/cli/blob/trunk/docs/install_linux.md
> [^2]:https://linux.die.net/man/5/watchdog.conf
