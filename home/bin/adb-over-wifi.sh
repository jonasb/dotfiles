#!/bin/bash
adb -d wait-for-device
echo Getting IP address from device
adb shell ip -f inet addr show
echo Enabling ADB over wifi on device
adb shell setprop service.adb.tcp.port 5555
echo Connect to device using:
echo "while {true} { adb connect IP; adb shell }"
echo  Use adb usb to return to normal
