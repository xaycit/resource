#!/system/bin/sh

TH="com.dts.freefireth"
MAX="com.dts.freefiremax"

STATE="stop"
GAME_STARTED=0

VAL="/storage/emulated/0/value"
PIDFILE="/storage/emulated/0/ff_tweak.pid"
LOG="/storage/emulated/0/ff_tweak.log"

if [ -f "$PIDFILE" ]; then
    exit
fi

echo $$ > "$PIDFILE"
trap "rm -f $PIDFILE" EXIT

# refresh rate
HZ=$(dumpsys display | grep -Eo 'fps=[0-9]+' | cut -d= -f2 | sort -n | tail -1)
[ -z "$HZ" ] && HZ=120
DEFHZ=60

# density
DENS=$(wm density | awk '/Override density/ {print $NF}')
[ -z "$DENS" ] && DENS=$(wm density | awk '/Physical density/ {print $NF}')

if [ ! -f "$VAL" ]; then
    echo "$DENS" > "$VAL"
else
    DENS=$(cat "$VAL")
fi

NEWD=290

# hitung dp
RES=$(wm size | awk -F '[ x]' '/Override size/ {print $3} /Physical size/ {p=$3} END{if($0!~/Override size/) print p}')
DP=$(( RES * 160 / NEWD ))

while true; do

pid1=$(pidof "$TH")
pid2=$(pidof "$MAX")

FOREGROUND=$(dumpsys window | grep -E 'mCurrentFocus|mFocusedApp' | grep -oE 'com\.[a-zA-Z0-9._]+' | head -n1)

echo "$(date) PID1:$pid1 PID2:$pid2 FG:$FOREGROUND GAME_STARTED:$GAME_STARTED STATE:$STATE" >> "$LOG"

if [ "$FOREGROUND" = "$TH" ] || [ "$FOREGROUND" = "$MAX" ]; then
    GAME_STARTED=1
fi

    if [ "$GAME_STARTED" = "1" ] && { [ -n "$pid1" ] || [ -n "$pid2" ]; }; then

        if [ "$STATE" = "stop" ]; then

            wm density "$NEWD"

            cmd power set-mode 0
            settings put global low_power 0
            cmd power set-adaptive-power-saver-enabled false

            settings put system peak_refresh_rate "$HZ"
            settings put system min_refresh_rate "$HZ"
            settings put secure peak_refresh_rate "$HZ"
            settings put secure min_refresh_rate "$HZ"

            settings put system glove_mode 1
            settings put system screen_glove_mode_enabled 1

            settings put global window_animation_scale 0
            settings put global transition_animation_scale 0
            settings put global animator_duration_scale 0

            settings put system pointer_speed 7
            settings put system pointer_acceleration 1

            settings put system touchscreen_sensitivity_mode 3
            settings put system touchscreen_threshold 9
            settings put secure tap_duration_threshold 0.0

            setprop debug.performance.tuning 1
            cmd power set-fixed-performance-mode-enabled true

            cmd notification post -S bigtext -t "Compiler Activated" Tag \
"Tweak Superior By Lanzsettings
DPI Di Ubah Menjadi: $DP dp" Tag >/dev/null 2>&1

            STATE="run"
        fi

    else

        if [ "$STATE" = "run" ]; then

            cmd notification post -S bigtext -t "Compiler Deactivated" Tag \
"Tweak Superior By Lanzsettings" Tag >/dev/null 2>&1

            wm density "$DENS"
            rm -f $PIDFILE

            settings put system peak_refresh_rate "$DEFHZ"
            settings put system min_refresh_rate "$DEFHZ"
            settings put secure peak_refresh_rate "$DEFHZ"
            settings put secure min_refresh_rate "$DEFHZ"

            cmd power set-mode 1
            settings put global low_power 1
            cmd power set-adaptive-power-saver-enabled true

            settings put system accelerometer_rotation 1

            settings put system glove_mode 0
            settings put system screen_glove_mode_enabled 0

            settings put global window_animation_scale 1
            settings put global transition_animation_scale 1
            settings put global animator_duration_scale 1

            settings put system pointer_speed 3
            settings put system pointer_acceleration 0

            settings delete system touchscreen_sensitivity_mode
            settings delete system touchscreen_threshold
            settings delete system touchscreen_sensitivity

            setprop debug.performance.tuning 0
            cmd power set-fixed-performance-mode-enabled false

            GAME_STARTED=0
            STATE="stop"
        fi

    fi

    sleep 2
done
