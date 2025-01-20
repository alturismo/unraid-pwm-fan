#!/bin/bash

source /boot/config/plugins/pwm-fan/pwmfansettings

if [ ! -z "$hdd_cron_time" ]; then
( crontab -l | grep -v -F "HDD " ; echo "# Cron Job for HDD pwm-fan plugin" ) | crontab -
( crontab -l | grep -v -F "pwm_hdd.sh" ; echo "$hdd_cron_time /usr/local/emhttp/plugins/pwm-fan/scripts/pwm_hdd.sh >/dev/null 2>&1" ) | crontab -
sed -i 's/^hdd_cron_state=.*/hdd_cron_state="started"/' /boot/config/plugins/pwm-fan/pwmfansettings
else
crontab -l | grep -v "HDD "  | crontab -
crontab -l | grep -v "pwm_hdd.sh"  | crontab -
sed -i 's/^hdd_cron_state=.*/hdd_cron_state="stopped"/' /boot/config/plugins/pwm-fan/pwmfansettings
fi