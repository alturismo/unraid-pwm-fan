#!/bin/bash

pwm_fan_log_log="/usr/local/emhttp/plugins/pwm-fan/pwm_log.txt"

cat /var/log/syslog | grep -i "pwm.*fan:" > $pwm_fan_log_log
tail -n 999 $pwm_fan_log_log > mypwmfile.tmp
cat mypwmfile.tmp > $pwm_fan_log_log
rm mypwmfile.tmp
