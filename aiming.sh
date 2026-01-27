#!/bin/sh

HZ_URL="https://raw.github.com/LanzXsettings/Macro-Modz/resource/HZConfig"

TH="com.dts.freefireth"
MAX="com.dts.freefiremax"

fetch() {
    url "$1"
    out "$2"

    if command -v curl >/dev/null 2>&1; then
        [ -n "$out" ] && curl -fsSL "$url" -o "$out" || curl -fsSL "$url"
    elif command -v wget >/dev/null 2>&1; then
        [ -n "$out" ] && wget -qO "$out" "$url" || wget -qO- "$url"
    fi
}

exechz() {
    fetch "$HZ_URL" >/dev/null 2>&1
}

run_game_setup() {
    cmd game downscale 1.8 "$TH"
    cmd device_config put game_overlay "$TH" mode=2,downscaleFactor=1.8
    cmd package compile -m speed --secondary-dex "$TH"
    cmd appops set "$TH" RUN_IN_BACKGROUND

    cmd game downscale 1.8 "$MAX"
    cmd device_config put game_overlay "$MAX" mode=2,downscaleFactor=1.8
    cmd package compile -m speed --secondary-dex "$MAX"
    cmd appops set "$MAX" RUN_IN_BACKGROUND

    setprop debug.hwui.renderer skiagl
    setprop debug.renderengine.backend skiagl
    dumpsys deviceidle force-idle
    cmd looper_stats disable
}

system_tweaks() {
    dumpsys deviceidle whitelist +"$TH" >/dev/null 2>&1
    dumpsys deviceidle whitelist +"$MAX" >/dev/null 2>&1

    setprop false debug.egl.force_msaa
    setprop false debug.egl.force_fxaa
    setprop false debug.egl.force_taa
    setprop false debug.egl.force_smaa

    setprop true debug.hwui.skip_empty_damage
    setprop true debug.hwui.capture_skp_enabled
    setprop 2 debug.hwui.capture_skp_frames

    cmd device_config put touchscreen input_drag_min_switch_speed 450
    settings put secure touch_blocking_period 0

    settings put system glove_mode 1
    settings put system screen_glove_mode_enabled 1

    settings put global window_animation_scale 0.5
    settings put global transition_animation_scale 0.5
    settings put global animator_duration_scale 0.5

    cmd device_config put input_native_boot palm_rejection_enabled 0
    settings put system pointer_speed 7
    settings put system pointer_acceleration 1

    settings put system touchscreen_sensitivity_mode 3
    settings put system touchscreen_threshold 9
    settings put system touchscreen_sensitivity 10
    settings put system touchscreen_min_press_time 50
    
    setprop 3000 debug.slow_query_threshold
    setprop debug.tracing.block_touch_buffer 1

    settings put global touch.pressure.scale 0.001
    settings put system touch.pressure.scale 0.001

    settings put secure tap_duration_threshold 0.0

    settings put system touch.scroll.calibration physical
    settings put system touch.surface_flinger.calibration physical
    settings put system touch.input_flinger.calibration physical
}

fps_calibration() {
    fps "$(dumpsys display | grep -Eo 'fps=[0-9]+' | cut -d= -f2 | sort -n | tail -n1)"
    [ -z "$fps" ] && fps 60

    cmd game set --fps "$fps" "$TH"
    cmd device_config put game_overlay "$TH" fps="$fps"

    cmd game set --fps "$fps" "$MAX"
    cmd device_config put game_overlay "$MAX" fps="$fps"

    frame_ns $((1000000000 / fps))
    phase_offset $((frame_ns / 4))

    setprop debug.sf.high_fps_early_gl_phase_offset_ns "$phase_offset"
    setprop debug.sf.high_fps_early_phase_offset_ns "$phase_offset"
    setprop debug.sf.high_fps_late_app_phase_offset_ns "$phase_offset"
    setprop debug.sf.high_fps_late_sf_phase_offset_ns "$phase_offset"
}

external_exe() {
    input swipe \
        $((RANDOM%1000)) $((RANDOM%1000)) \
        $((RANDOM%1000)) $((RANDOM%1000)) \
        $((RANDOM%1000+500)) -1
}

aim_tracking_opt() {
    v "$1"
    [ "$v" -lt 0 ] && v 0
    [ "$v" -gt 1000 ] && v 1000
    echo "$v"
}

sensi_calibrar() {
    x "$(aim_tracking_opt $((RANDOM%1000)))"
    y "$(aim_tracking_opt $((RANDOM%1000)))"
    d $((RANDOM%1000+500))

    input swipe "$x" "$y" 2000 2000 "$d" -1
    input swipe "$x" "$y" 2000 0 "$d" -1
    input swipe "$x" "$y" 0 2000 "$d" -1
    input swipe "$x" "$y" 0 0 "$d" -1
}

main() {
    detect_game
    run_game_setup
    system_tweaks
    fps_calibration
    external_exe
    sensi_calibrar
    exechz
}

main >/dev/null 2>&1
