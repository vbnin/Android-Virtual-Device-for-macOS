#!/bin/bash

####################################################################################################
#
### Written by: Vincent Bonnin - Technical Enablement Manager at Jamf
### Last updated on 25 Nov 2024
#
### This script will install Android Device Manager CLI tools and its prerequisites prior to create Android virtual devices
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
#	   Scripts and create a new script. Copy this script in full to the
#	   script body and save. Add a label for script parameter 4 like 'Custom device folder:'
#
#	4) (Optional) Then choose Computers > Policies and create a new policy. Add
#	   the script to the policy and enable it for Self Service. Fill script parameter #4 if needed.
#
#	5) On the computer, run the script from Jamf Self Service or directly by executing this .sh file. Android Device Manager should now be installed.
#
####################################################################################################

echo "Starting script to install Android Device Manager CLI tools"

# Editable variables (edit only if needed)
DOWNLOAD_URL="https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip"    # Define the download URL of Android CLI tools
SDK_ROOT="/Library/Android/SDK"    # Define the root install path of Android CLI tools

# Jamf Pro variables (optional, you can leave the variable blank)
CUSTOM_WORKING_DIR="$4"   # Define a custom directory to store Android virtual devices for easy access

# Fixed variables
ZSHRC_FILE="/etc/zshrc"
CONSOLE_USER="$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )"
DEFAULT_WORKING_DIR="/private/var/root/.android"

# Create symbolic link to custom device image location if required
if [[ -z "$CUSTOM_WORKING_DIR" ]]; then
  # Keep default directory to store devices
  WORKING_DIR="$DEFAULT_WORKING_DIR"
else
  # Use custom directory to store devices
  WORKING_DIR="$CUSTOM_WORKING_DIR"
  mkdir -p "$WORKING_DIR"
  chmod 777 "$WORKING_DIR"

  # Backup existing .android folder if it exists
  mv -f /private/var/root/.android /private/var/root/.android-backup

  # Create a symlink between default folder and custom set folder
  ln -sf ${WORKING_DIR} /private/var/root/.android
fi

echo "Future virtual devices will be created in: $WORKING_DIR"

# Create SDK root directory
SDK_PATH="${SDK_ROOT}/cmdline-tools/latest"
echo "Setting SDK install directory to ${SDK_PATH}"
mkdir -p "${SDK_PATH}"
chmod 755 "${SDK_PATH}"

# Check if JDK is installed
echo "Checking if Java JDK 21 or later is installed on this Mac"

# Extract the major version number
JAVA_VERSION=$(java -version 2>&1 | grep -oE '"[0-9]+(\.[0-9]+)*"' | tr -d '"')
JAVA_MAJOR_VERSION=$(echo "$JAVA_VERSION" | cut -d'.' -f1)

# Check if the version is >= 21
if [ "$JAVA_MAJOR_VERSION" -ge 21 ]; then
  echo "Java JDK 21 or later is installed. Proceeding..."
  # Proceed with the script
else
  echo "Java JDK is not installed or below the required version. Cannot proceed..."
  # Install JDK21 from a Jamf Pro policy or by any other mean
  # /usr/local/bin/jamf policy -event @install-jdk21    # Example Jamf Pro policy to install JDK21
  exit 1
fi

# Configure environment variables
echo "Setting environment variables for Android Device Manager"
NEW_ENV_VARS="
# Android SDK environment variables
export ANDROID_SDK_ROOT=${SDK_PATH}
export ANDROID_HOME=${SDK_PATH}
export ANDROID_AVD_HOME=${WORKING_DIR}/avd
"

NEW_PATHS=(
  "${SDK_ROOT}/emulator"
  "${SDK_ROOT}/platform-tools"
  "${SDK_PATH}/bin"
)

# Check if the environment variables are already in the file
if ! grep -q "ANDROID_SDK_ROOT" "$ZSHRC_FILE"; then
  echo "Adding Android SDK environment variables to $ZSHRC_FILE..."
  
  # Append the environment variables to the file
  echo "$NEW_ENV_VARS" | sudo tee -a "$ZSHRC_FILE" > /dev/null
  
  echo "Environment variables added successfully!"
else
  echo "Android SDK environment variables already exist in $ZSHRC_FILE."
fi

# Add additional paths to the file
echo "Adding paths to PATH in $ZSHRC_FILE..."
for path in "${NEW_PATHS[@]}"; do
  # Check if the path is already in the PATH variable
  if ! grep -q "$path" "$ZSHRC_FILE"; then
  	echo "Adding $path to PATH..."
  	echo "export PATH=\$PATH:$path" | sudo tee -a "$ZSHRC_FILE" > /dev/null
  else
  	echo "$path is already in $ZSHRC_FILE. Skipping..."
  fi
done

# Reload the zshrc file to apply environment variable changes
echo "Reloading $ZSHRC_FILE for root and logged-in user..."
cd /tmp/
source "$ZSHRC_FILE"
sudo -H -iu ${CONSOLE_USER} source "$ZSHRC_FILE"

# Download and install Android CLI Tools
echo "Downloading and extracting Android CLI Tools"
curl -L -o /tmp/cli.zip "$DOWNLOAD_URL"
unzip -qq /tmp/cli.zip -d ${SDK_PATH}/tmp
mv ${SDK_PATH}/tmp/cmdline-tools/* ${SDK_PATH}
rm -rf ${SDK_PATH}/tmp

# Check if SDK manager has been properly installed before proceeding
if [[ ! -e "${SDK_PATH}/bin/sdkmanager" ]]; then
  echo "The sdkmanager binary hasn't been found in ${SDK_PATH}/bin. Maybe check the download URL is still valid? Exiting now..."
  exit 1
fi

# Install additional resources needed by Android CLI tools
echo "Installing additional SDK tools"
echo y | ${SDK_PATH}/bin/sdkmanager --licenses
echo y | ${SDK_PATH}/bin/sdkmanager --install "platform-tools"
echo y | ${SDK_PATH}/bin/sdkmanager --install "emulator"
echo y | ${SDK_PATH}/bin/sdkmanager --install "build-tools;35.0.0"
echo y | ${SDK_PATH}/bin/sdkmanager --install "platforms;android-35"

echo "Done!"

exit 0
