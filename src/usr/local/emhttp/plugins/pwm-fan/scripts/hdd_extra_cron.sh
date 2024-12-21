#!/bin/bash

source /boot/config/plugins/pwm-fan/pwmfansettings

if [ ! -z "$hdd_extra_cron_time" ]; then
( crontab -l | grep -v -F "HDDextra" ; echo "# Cron Job for HDDextra pwm-fan plugin" ) | crontab -
( crontab -l | grep -v -F "pwm_hdd_extra.sh" ; echo "$hdd_extra_cron_time /usr/local/emhttp/plugins/pwm-fan/scripts/pwm_hdd_extra.sh" ) | crontab -
sed -i 's/^hdd_extra_cron_state=.*/hdd_extra_cron_state="started"/' /boot/config/plugins/pwm-fan/pwmfansettings
else
crontab -l | grep -v "HDDextra"  | crontab -
crontab -l | grep -v "pwm_hdd_extra.sh"  | crontab -
sed -i 's/^hdd_extra_cron_state=.*/hdd_extra_cron_state="stopped"/' /boot/config/plugins/pwm-fan/pwmfansettings
fi