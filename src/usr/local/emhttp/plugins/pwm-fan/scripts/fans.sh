#!/bin/bash

ls -l /sys/devices/platform/*/*/*/*pwm*_enable | cut -f10 -d' ' > /boot/config/plugins/pwm-fan/fanssettings

pwm_control=$(tail -1 /boot/config/plugins/pwm-fan/fanssettings |  cut -f5 -d'/')
pwm_hwmonitor=$(tail -1 /boot/config/plugins/pwm-fan/fanssettings |  cut -f7 -d'/')
pwm_fan_number=$(tail -1 /boot/config/plugins/pwm-fan/fanssettings |  cut -f8 -d'/' | cut -f1 -d'_')

echo "Testing Fans in Unraids Terminal as sample" > /boot/config/plugins/pwm-fan/fanssettings_help
echo "------------------------------------------------------------------------" >> /boot/config/plugins/pwm-fan/fanssettings_help
echo "1. activate OS Control for a Fan" >> /boot/config/plugins/pwm-fan/fanssettings_help
echo "------------------------------------------------------------------------" >> /boot/config/plugins/pwm-fan/fanssettings_help
echo "echo 1 > /sys/devices/platform/"$pwm_control"/hwmon/$pwm_hwmonitor/"$pwm_fan_number"_enable" >> /boot/config/plugins/pwm-fan/fanssettings_help
echo "------------------------------------------------------------------------" >> /boot/config/plugins/pwm-fan/fanssettings_help
echo "Info, echo 1 > ... once done the fan is controlled only by OS" >> /boot/config/plugins/pwm-fan/fanssettings_help
echo "to return to BIOS Control, most likely a reboot is required" >> /boot/config/plugins/pwm-fan/fanssettings_help
echo "------------------------------------------------------------------------" >> /boot/config/plugins/pwm-fan/fanssettings_help
echo "2. set speed value for a Fan from 0 - 255" >> /boot/config/plugins/pwm-fan/fanssettings_help
echo "------------------------------------------------------------------------" >> /boot/config/plugins/pwm-fan/fanssettings_help
echo "echo 255 > /sys/devices/platform/"$pwm_control"/hwmon/$pwm_hwmonitor/$pwm_fan_number" >> /boot/config/plugins/pwm-fan/fanssettings_help
echo "------------------------------------------------------------------------" >> /boot/config/plugins/pwm-fan/fanssettings_help
echo "Info, echo 0 - 255 > ... to check if pwm control is functional" >> /boot/config/plugins/pwm-fan/fanssettings_help
echo "while 0 is off and 255 is max" >> /boot/config/plugins/pwm-fan/fanssettings_help
echo "note your prefered min / max values for setup" >> /boot/config/plugins/pwm-fan/fanssettings_help
echo "------------------------------------------------------------------------" >> /boot/config/plugins/pwm-fan/fanssettings_help
echo "Fans which are adjustable can be setted up for HDD / CPU setup" >> /boot/config/plugins/pwm-fan/fanssettings_help
echo "------------------------------------------------------------------------" >> /boot/config/plugins/pwm-fan/fanssettings_help

exit;