#!/bin/sh

scrcpy -d
ANDROID_SERIAL=988e5035584a354b4430 droidcam-cli -a -v -size=1920x1080 adb 4747
