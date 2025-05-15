# Android-Virtual-Device-for-macOS
__Generate and run fully functional Android virtual devices on macOS in a few clicks!__

Are you looking to easily create and run Android virtual devices on macOS? You're in the right place!
I created these 3 scripts as I needed a way to easily experiment with Android devices in the Jamf Security Cloud portal.


<img width="1440" alt="Screenshot 2024-11-26 at 16 52 55 (2)" src="https://github.com/user-attachments/assets/315d8c99-d6ca-40fa-814d-94bd4e4517e1">

## Requirements
These scripts have been designed to be deployed using Jamf Pro policies, but they can also be used as stand-alone scripts.
This is a personal project tested in the following environment:
* Mac Mini M1 with macOS Sequoia 15.1
* Java JDK 21 LTS installed
* Jamf Pro 11.11.2

## Instructions
Instructions are given at the beginning of each script, here are some general instructions for the whole setup

1. Ensure Java JDK 21 or later is installed with the command ```java -version```. JDK 21 for Mac can be installed from there: https://adoptium.net/en-GB/temurin/releases/?os=mac&package=jdk&version=21
2. Edit variables in all three scripts according to your context and your needs (install path, device name, etc). This step is optional, leaving variables by default will work anyway.
3. Run the _bash_ script **android_device_manager_install.sh** first to install Android CLI tools on your Mac.
Example: ```sudo bash android_device_manager_install.sh```
4. Run the _zsh_ script **create_android_virtual_device.sh** as many times as you want to create new Android virtual devices.
Don't forget to set a different device name in script variables each time you want to create a new one.
Example: ```sudo zsh create_android_virtual_device.sh```
5. Run the _zsh_ script **script run_android_virtual_device.sh** every time you want to run an Android device
Don't forget to set a different device name in script variables to run the correct device.
Example: ```sudo zsh run_android_virtual_device.sh```

## Tips
* Execute these scripts as root or using ```sudo```
* Pay attention to script types, the install script is BASH and the other ones are ZSH
* Environment and PATH variables are important to make this setup work, you can check everything is defined correctly by running ```cat /etc/zshrc```. If needed, you can refresh your environment variables by running ```source /etc/zshrc```.
* You can list all available Android system images by running the command ```sdkmanager --list```
* You can kill a running device by running the command ```adb emu kill &```
* You can list available devices by running the command ```emulator -list-avds```

## Sources used to build these scripts
* https://medium.com/michael-wallace/how-to-install-android-sdk-and-setup-avd-emulator-without-android-studio-aeb55c014264
* https://developer.android.com/studio
