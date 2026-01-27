#!/bin/sh

hz="https://raw.github.com/LanzXsettings/Macro-Modz/resource/delHZConfig"

fetch() {
    url "$1"
    out "$2"

    if command -v curl >/dev/null 2>&1; then
        [ -n "$out" ] && curl -fsSL "$url" -o "$out" >/dev/null 2>&1 || curl -fsSL "$url"
    elif command -v wget >/dev/null 2>&1; then
        [ -n "$out" ] && wget -qO "$out" "$url" >/dev/null 2>&1 || wget -qO- "$url"
    fi
}

exechz() {
    fetch "$hz"
}

main() {
    cmd game reset com.dts.freefireth
    cmd game reset com.dts.freefiremax

    cmd game downscale disable com.dts.freefireth
    cmd game downscale disable com.dts.freefiremax

    device_config delete game_overlay com.dts.freefireth
    device_config delete game_overlay com.dts.freefiremax

    dumpsys deviceidle whitelist -com.dts.freefireth >/dev/null 2>&1
    dumpsys deviceidle whitelist -com.dts.freefiremax >/dev/null 2>&1

    settings put secure long_press_timeout 300
    settings put secure multi_press_timeout 300

    cmd device_config delete touchscreen input_drag_min_switch_speed

    settings put system pointer_speed 0
    settings put system pointer_acceleration 0

    cmd power set-adaptive-power-saver-enabled true
    cmd power set-fixed-performance-mode-enabled false
    cmd power set-mode 1

    cmd thermalservice override-status 1

    cmd compile -m everything --reset com.dts.freefireth
    cmd compile -m everything --reset com.dts.freefiremax

    settings put secure touch_blocking_period 500

    settings put system glove_mode 0
    settings put system screen_glove_mode_enabled 0

    settings put global window_animation_scale 1.0
    settings put global transition_animation_scale 1.0
    settings put global animator_duration_scale 1.0

    settings delete global touch.pressure.scale
    settings delete system touch.pressure.scale
    settings delete secure tap_duration_threshold
    settings delete secure touch_blocking_period
    settings delete system touch.scroll.calibration
    settings delete system touch.surface_flinger.calibration
    settings delete system touch.input_flinger.calibration

    cmd device_config delete input_native_boot palm_rejection_enabled

    pkill -f dpi
}

main >/dev/null 2>&1
exechz >/dev/null 2>&1
