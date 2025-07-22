#!/system/bin/sh

# Target packages
PKG1="com.dts.freefireth"
PKG2="com.dts.freefiremax"

STATE="stopped"

# Detect maximum supported refresh rate (fallback: 120)
MAX_HZ=$(dumpsys display | grep -Eo 'modeId.*[0-9]+Hz' | grep -Eo '[0-9]+(?=Hz)' | sort -nr | head -n1)
[ -z "$MAX_HZ" ] && MAX_HZ=120

DEFAULT_HZ=60

while true; do
    # Get foreground app
    FOREGROUND_APP=$(dumpsys window | grep -E 'mCurrentFocus|mFocusedApp' | grep -oE 'com\.[a-zA-Z0-9._]+')

    if [ "$FOREGROUND_APP" = "$PKG1" ] || [ "$FOREGROUND_APP" = "$PKG2" ]; then
        if [ "$STATE" = "stopped" ]; then
            cmd notification post -S bigtext -t 'Smart Dpi By Lanzsettings' 'Tag' 'Active' > /dev/null 2>&1

            wm density 265

            # Apply max refresh rate to system and secure
            settings put system peak_refresh_rate "$MAX_HZ"
            settings put system min_refresh_rate "$MAX_HZ"
            settings put secure peak_refresh_rate "$MAX_HZ"
            settings put secure min_refresh_rate "$MAX_HZ"

            STATE="running"
        fi
    else
        if [ "$STATE" = "running" ]; then
            cmd notification post -S bigtext -t 'Smart Dpi By Lanzsettings' 'Tag' 'Not Active' > /dev/null 2>&1

            wm density reset

            # Reset refresh rate
            settings put system peak_refresh_rate "$DEFAULT_HZ"
            settings put system min_refresh_rate "$DEFAULT_HZ"
            settings put secure peak_refresh_rate "$DEFAULT_HZ"
            settings put secure min_refresh_rate "$DEFAULT_HZ"

            STATE="stopped"
        fi
    fi

    sleep 2
done

exit 0
