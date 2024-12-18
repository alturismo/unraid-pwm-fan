#!/bin/bash

cat /var/log/syslog | grep -i "pwm.*fan:" > /usr/local/emhttp/plugins/pwm-fan/pwm_log.txt
