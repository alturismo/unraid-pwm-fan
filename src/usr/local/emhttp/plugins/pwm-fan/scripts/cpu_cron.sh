#!/bin/bash

source /boot/config/plugins/pwm-fan/pwmfansettings

if [ ! -z "$cron_time" ]; then
( crontab -l | grep -v -F "CPU" ; echo "# Cron Job for CPU pwm-fan plugin" ) | crontab -
( crontab -l | grep -v -F "pwm-fan.sh" ; echo "$cron_time /usr/local/emhttp/plugins/pwm-fan/scripts/pwm-fan.sh" ) | crontab -
sed -i 's/^cron_state=.*/cron_state="started"/' /boot/config/plugins/pwm-fan/pwmfansettings
else
crontab -l | grep -v "CPU"  | crontab -
crontab -l | grep -v "pwm-fan.sh"  | crontab -
sed -i 's/^cron_state=.*/cron_state="stopped"/' /boot/config/plugins/pwm-fan/pwmfansettings
fi