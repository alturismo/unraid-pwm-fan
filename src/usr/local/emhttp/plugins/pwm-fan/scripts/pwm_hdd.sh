#!/bin/bash

source /boot/config/plugins/pwm-fan/pwmfansettings

############### End config

if [ "$syslog" == "yes" ]; then

log_message() {
  while IFS= read -r line; do
    logger "pwm-hdd-fan: ${line}"
  done
}
exec > >(log_message) 2>&1

fi

# find /sys/devices/platform/ -type f -name "*pwm*_enable" -print 2>/dev/null

### Sensor read HDD Temp, check
pwmhddechoinfo=""
hdd_array=()

for pwm_disk in $hdd_pwm_hdd
	do
	_temp=$(smartctl --nocheck standby -iA /dev/$pwm_disk | egrep ^194 | awk '{print $4}' | sed 's/^0*//')
	[ -z $_temp ] && _temp="0"
	hdd_array+=($_temp)
	#echo $(printf '%s\n' "${hdd_array[@]}")
	done

### fetch highest temparured disk from array
current_temp=$( printf "%d\n" "${hdd_array[@]}" | sort -n | tail -1 )

### Script starts here, rolling through fans
for hdd_pwm_fans in $hdd_pwm_fan
	do

### Sensor enable OS control
echo 1 > /sys/devices/platform/$hdd_pwm_controller/hwmon/$hdd_pwm_hwmon/"$hdd_pwm_fans"_enable

### Control file for hysterie target <> start temp
fan_on="/usr/local/emhttp/plugins/pwm-fan/"$hdd_pwm_fans"_hddfan_on"

### Fan adjustments
if (( "$current_temp" < "$hdd_target_temp" )); then
	pwm_set=0
	echo $pwm_set > /sys/devices/platform/$hdd_pwm_controller/hwmon/$hdd_pwm_hwmon/$hdd_pwm_fans
	if [[ -f "$fan_on" ]]; then
		rm "$fan_on"
		pwmhddechoinfo="set fan off"
	fi
fi

if [[ -f "$fan_on" ]] && (( "$current_temp" >= "$hdd_target_temp" )) && (("$current_temp" < "$hdd_start_temp" )); then
	pwm_set=$hdd_min_rpm
	echo $pwm_set > /sys/devices/platform/$hdd_pwm_controller/hwmon/$hdd_pwm_hwmon/$hdd_pwm_fans
	touch $fan_on
	pwmhddechoinfo="fan is on and set fan to min $hdd_min_rpm until target is reached"
fi

if (( "$current_temp" >= "$hdd_max_temp" )); then
	pwm_set=$hdd_max_rpm
	echo $pwm_set > /sys/devices/platform/$hdd_pwm_controller/hwmon/$hdd_pwm_hwmon/$hdd_pwm_fans
	touch $fan_on
	pwmhddechoinfo="set fan to max $hdd_max_rpm"
fi

if (( "$current_temp" >= "$hdd_start_temp" )) && (( "$current_temp" < "$hdd_max_temp" )); then
	temp_offset=$(expr $current_temp - $hdd_start_temp)
	rpm_range=$(expr $hdd_max_rpm - $hdd_min_rpm)
	temp_range=$(expr $hdd_max_temp - $hdd_start_temp)
	offset_multi=$(echo $rpm_range $temp_range | awk '{print $1 / $2}')
	temp_offset=$(echo $temp_offset $offset_multi | awk '{print $1 * $2}')
	pwm_set=$(echo $hdd_min_rpm $temp_offset | awk '{print $1 + $2}')
	pwm_set=$(echo $pwm_set | awk '{print int($1 + 0.5) }')
	echo $pwm_set > /sys/devices/platform/$hdd_pwm_controller/hwmon/$hdd_pwm_hwmon/$hdd_pwm_fans
	touch $fan_on
	pwmhddechoinfo="set fan to value $pwm_set"
fi

	done

if [[ ! -z $pwmhddechoinfo ]]; then
	echo $pwmhddechoinfo
fi

exit;
