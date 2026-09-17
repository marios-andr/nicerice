#!/usr/bin/env bash

# battery-notification.sh
# Watches battery capacity and sends a desktop notification at low (20%)
# and critical (5%).

LOW_THRESHOLD=20
CRITICAL_THRESHOLD=5
POLL_INTERVAL=60   # seconds between checks

# Auto-detect the first battery under /sys/class/power_supply
BATTERY_PATH=""
for bat in /sys/class/power_supply/BAT*; do
    if [ -d "$bat" ]; then
        BATTERY_PATH="$bat"
        break
    fi
done

if [ -z "$BATTERY_PATH" ]; then
    echo "Error: No battery found under /sys/class/power_supply/BAT*."
    exit 1
fi

get_capacity() {
    cat "$BATTERY_PATH/capacity" 2>/dev/null
}

get_status() {
    cat "$BATTERY_PATH/status" 2>/dev/null
}

notify() {
    local urgency="$1"
    local title="$2"
    local body="$3"
    notify-send -u "$urgency" -i battery-low "$title" "$body"
}

# Track whether we've already fired a notification for the current dip,
# so we don't spam it every poll interval while sitting below a threshold.
low_notified=0
critical_notified=0

while true; do
    capacity=$(get_capacity)
    status=$(get_status)

    if [ -z "$capacity" ]; then
        sleep "$POLL_INTERVAL"
        continue
    fi

    # Reset notification flags once charging starts or level recovers
    if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
        low_notified=0
        critical_notified=0
    fi

    if [ "$capacity" -le "$CRITICAL_THRESHOLD" ] && [ "$status" != "Charging" ]; then
        if [ "$critical_notified" -eq 0 ]; then
            notify "critical" "Battery Critical" "Battery at ${capacity}%. Plug in now to avoid shutdown."
            critical_notified=1
            low_notified=1  # critical implies low already handled
        fi
    elif [ "$capacity" -le "$LOW_THRESHOLD" ] && [ "$status" != "Charging" ]; then
        if [ "$low_notified" -eq 0 ]; then
            notify "normal" "Battery Low" "Battery at ${capacity}%. Consider plugging in."
            low_notified=1
        fi
    fi

    sleep "$POLL_INTERVAL"
done