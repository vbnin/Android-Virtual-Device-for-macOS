#!/bin/bash

####################################################################################################
#
### Written by: Vincent Bonnin - Technical Enablement Manager at Jamf
### Last updated on 25 Nov 2024
#
### This script will create an Android virtual device using Android CLI tools
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
#	3) (Optional) In Jamf Pro choose Settings (cog wheel) > Computer Mangement >
#	   Scripts and create a new script. Copy this script in full to the script body and save.
#
#	4) (Optional) Then choose Computers > Policies and create a new policy. Add
#	   the script to the policy and enable it for Self Service.
#
#	5) On the computer, run the script from Jamf Self Service or directly by executing this .sh file.
#    A new Android virtual devices should have been created on the computer.
#
####################################################################################################

# Editable variables
SDK_ROOT="/Library/Android/SDK"    # Android CLI tools install path
ANDROID_PACKAGE="system-images;android-35;google_apis_playstore;arm64-v8a"    # Android system image used to create the virtual device
DEVICE_NAME="My Android Device"    # Name of your new Android virtual device

# Fixed variables
SDK_BIN="${SDK_ROOT}/cmdline-tools/latest/bin"

echo "Android SDK root is: $SDK_ROOT"

# Check Android CLI tools presence
echo "Checking if sdkmanager binary is properly installed"
if [[ ! -e "${SDK_BIN}/avdmanager" ]]; then
	echo "Android CLI tools could not be found at ${SDK_BIN}/, cannot proceed..."
    exit 1
fi

# Create the VM
echo "Preparing to create a new Android virtual device..."
echo "Device settings: Package=${ANDROID_PACKAGE}, Name=${DEVICE_NAME}"

echo no | ${SDK_BIN}/avdmanager create avd --name "${DEVICE_NAME}" --package "$ANDROID_PACKAGE"

echo "Done!"

# List available VMs
DEVICE_LIST=$(${SDK_BIN}/avdmanager list avd | grep 'Name:' | awk '{print "" $2}')

echo "Android virtual devices available:"
echo "${DEVICE_LIST[*]}"

echo "Script complete"

exit 0
