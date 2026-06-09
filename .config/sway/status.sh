#!/bin/bash

while true; do
    # Volume
    vol=$(amixer get Master | grep "Right:" | cut -f 7,8 -d " ")
    vol_str="VOL ${vol}"

    # Battery
    bat_cap_file="/sys/class/power_supply/BAT0/capacity"
    bat_status_file="/sys/class/power_supply/BAT0/status"
    if [[ -f "$bat_cap_file" && -f "$bat_status_file" ]]; then
        bat_pct=$(cat "$bat_cap_file")
        bat_status=$(cat "$bat_status_file")
        case "$bat_status" in
            Charging)    icon="↑" ;;
            Discharging) icon="↓" ;;
            Full)        icon="=" ;;
            *)           icon="?" ;;
        esac
        bat_str="BAT ${bat_pct}% ${icon}"
    else
        bat_str=""
    fi

    # Date/time
    dt=$(date +'%Y-%m-%d %X')

    # Assemble line
    if [[ -n "$bat_str" ]]; then
        echo "${vol_str} | ${bat_str} | ${dt}"
    else
        echo "${vol_str} | ${dt}"
    fi

    sleep 1
done
