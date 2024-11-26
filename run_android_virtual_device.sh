#!/bin/zsh

####################################################################################################
#
### Written by: Vincent Bonnin - Technical Enablement Manager at Jamf
### Last updated on 25 Nov 2024
#
### This script will run a given virtual device using Android CLI tools
### This script has been designed to be run from a Jamf Pro policy but it can also be run directly on a computer (root required)
### This script has been tested with the following setup:
#     - A MacBook Pro M1 (Silicon architecture)
#     - Java Open JDK 21 LTS installed
#
### INSTRUCTIONS
#
#	1) Ensure Java JDK21 is installed on the Mac by running the command 'java -version'.
#	   You can download an installer PKG here: https://adoptium.net/en-GB/temurin/releases/?os=mac&package=jdk&version=21
#
#	2) Review and edit the editable variables if needed
#	   
#	3) (Optional) In Jamf Pro choose Settings (cog wheel) > Computer Mangement > Scripts and create a new script.
#     Copy this script in full to the script body and save.
#
#	4) (Optional) Then choose Computers > Policies and create a new policy. Add the script to the policy and enable it for Self Service.
#
#	5) On the computer, run the script from Jamf Self Service or directly by executing this .sh file.
#    An Android device should appear on screen.
#
####################################################################################################


### This script will run a random virtual device from a given list using Android CLI tools
### Written by Vincent Bonnin
### 25 Nov 2024 - V1.0

# Editable variables
SDK_ROOT="/Library/Android/SDK"    # Android CLI tools install path
DEVICE_NAME="My_Android_Device"    # Name of your new Android virtual device. No spaces allowed. 

# Check if Android CLI tools are available
if [[ ! -e "$SDK_ROOT/emulator/emulator" ]]; then
	echo "Missing Android device emulator, cannot proceed..."
    exit 1
fi

# Reload /etc/zshrc to ensure PATH environment variables are accessible to emulator binary
source /etc/zshrc 2>/dev/null

echo "Starting Android device ==> ${DEVICE_NAME}"
${SDK_ROOT}/emulator/emulator -avd "${DEVICE_NAME}" &

# Uncomment the following lines to automatically stop Android emulator
# sleep 60
# echo "Stopping Android device ==> ${DEVICE_NAME}"
# ${SDK_ROOT}/platform-tools/adb emu kill &

echo "Script complete"

exit 0
