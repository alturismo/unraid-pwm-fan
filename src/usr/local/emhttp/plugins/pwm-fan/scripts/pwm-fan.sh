#!/bin/bash

source /boot/config/plugins/pwm-fan/pwmfansettings

### Check if another instance of this Program is running
pidof -o %PPID -x $0 >/dev/null && exit;

### aggresiv mode disabling syslog
if [[ ! -z $cron_seconds ]]; then
	syslog=""
fi

############### End config
if [ "$syslog" == "yes" ]; then

log_message() {
  while IFS= read -r line; do
    logger "pwm-fan: ${line}"
  done
}
exec > >(log_message) 2>&1

fi

### General
pwmechoinfo=""

### Control file for hysterie target <> start temp
fan_on="/usr/local/emhttp/plugins/pwm-fan/"$pwm_fan"_fan_on"

### Sensor readout current temp
current_temp=$(sensors | grep -i "CPU Temp" | awk '{print $3}' | egrep -o '[0-9.]+' | cut -d"." -f1)

### Sensor enable OS control
echo 1 > /sys/devices/platform/"$pwm_controller"/hwmon/$pwm_hwmon/"$pwm_fan"_enable

### Script starts here
if (( "$current_temp" < "$target_temp" )); then
	pwm_set=0
	echo $pwm_set > /sys/devices/platform/"$pwm_controller"/hwmon/$pwm_hwmon/$pwm_fan
	if [[ -f "$fan_on" ]]; then
		rm "$fan_on"
		pwmechoinfo="set fan off"
	fi
fi

if [[ -f "$fan_on" ]] && (( "$current_temp" >= "$target_temp" )) && (("$current_temp" < "$start_temp" )); then
	pwm_set=$min_rpm
	echo $pwm_set > /sys/devices/platform/"$pwm_controller"/hwmon/$pwm_hwmon/$pwm_fan
	touch $fan_on
	pwmechoinfo="fan is on and set fan to min $min_rpm until target is reached"
fi

if (( "$current_temp" >= "$max_temp" )); then
	pwm_set=$max_rpm
	echo $pwm_set > /sys/devices/platform/"$pwm_controller"/hwmon/$pwm_hwmon/$pwm_fan
	touch $fan_on
	pwmechoinfo="set fan to max $max_rpm"
fi

if (( "$current_temp" >= "$start_temp" )) && (( "$current_temp" < "$max_temp" )); then
	temp_offset=$(expr $current_temp - $start_temp)
	rpm_range=$(expr $max_rpm - $min_rpm)
	temp_range=$(expr $max_temp - $start_temp)
	offset_multi=$(echo $rpm_range $temp_range | awk '{print $1 / $2}')
	temp_offset=$(echo $temp_offset $offset_multi | awk '{print $1 * $2}')
	pwm_set=$(echo $min_rpm $temp_offset | awk '{print $1 + $2}')
	pwm_set=$(echo $pwm_set | awk '{print int($1 + 0.5) }')
	echo $pwm_set > /sys/devices/platform/"$pwm_controller"/hwmon/$pwm_hwmon/$pwm_fan
	touch $fan_on
	pwmechoinfo="set fan to value $pwm_set"
fi

if [[ ! -z $pwmechoinfo ]]; then
	echo $pwmechoinfo
fi

### if aggressiv rerun every N seconds
if [[ ! -z $cron_seconds ]]; then
	while sleep $cron_seconds; do

	source /boot/config/plugins/pwm-fan/pwmfansettings

	### stop in terms aggressiv is empty while running
	if [[ -z $cron_seconds ]]; then
		if [ "$syslog" == "yes" ]; then
			log_message() {
			while IFS= read -r line; do
			logger "pwm-fan: ${line}"
			done
		}
		exec > >(log_message) 2>&1
		fi
		echo "aggressiv mode deactivated, stopping now"
		exit;
	fi

	### General
	pwmechoinfo=""

	### Control file for hysterie target <> start temp
	fan_on="/usr/local/emhttp/plugins/pwm-fan/"$pwm_fan"_fan_on"

	### Sensor readout current temp
	current_temp=$(sensors | grep -i "CPU Temp" | awk '{print $3}' | egrep -o '[0-9.]+' | cut -d"." -f1)

	### Sensor enable OS control
	echo 1 > /sys/devices/platform/"$pwm_controller"/hwmon/$pwm_hwmon/"$pwm_fan"_enable

	### Script starts here
	if (( "$current_temp" < "$target_temp" )); then
		pwm_set=0
		echo $pwm_set > /sys/devices/platform/"$pwm_controller"/hwmon/$pwm_hwmon/$pwm_fan
		if [[ -f "$fan_on" ]]; then
			rm "$fan_on"
			pwmechoinfo="set fan off"
		fi
	fi

	if [[ -f "$fan_on" ]] && (( "$current_temp" >= "$target_temp" )) && (("$current_temp" < "$start_temp" )); then
		pwm_set=$min_rpm
		echo $pwm_set > /sys/devices/platform/"$pwm_controller"/hwmon/$pwm_hwmon/$pwm_fan
		touch $fan_on
		pwmechoinfo="fan is on and set fan to min $min_rpm until target is reached"
	fi

	if (( "$current_temp" >= "$max_temp" )); then
		pwm_set=$max_rpm
		echo $pwm_set > /sys/devices/platform/"$pwm_controller"/hwmon/$pwm_hwmon/$pwm_fan
		touch $fan_on
		pwmechoinfo="set fan to max $max_rpm"
	fi

	if (( "$current_temp" >= "$start_temp" )) && (( "$current_temp" < "$max_temp" )); then
		temp_offset=$(expr $current_temp - $start_temp)
		rpm_range=$(expr $max_rpm - $min_rpm)
		temp_range=$(expr $max_temp - $start_temp)
		offset_multi=$(echo $rpm_range $temp_range | awk '{print $1 / $2}')
		temp_offset=$(echo $temp_offset $offset_multi | awk '{print $1 * $2}')
		pwm_set=$(echo $min_rpm $temp_offset | awk '{print $1 + $2}')
		pwm_set=$(echo $pwm_set | awk '{print int($1 + 0.5) }')
		echo $pwm_set > /sys/devices/platform/"$pwm_controller"/hwmon/$pwm_hwmon/$pwm_fan
		touch $fan_on
		pwmechoinfo="set fan to value $pwm_set"
	fi

	if [[ ! -z $pwmechoinfo ]]; then
		echo $pwmechoinfo
	fi
	done
fi

exit;
