#!/bin/sh

TH="com.dts.freefireth"
MAX="com.dts.freefiremax"

run_game_setup() {
    cmd game downscale 2.5 "$TH"
    cmd device_config put game_overlay "$TH" mode=2,downscaleFactor=2.5

    cmd game downscale 2.5 "$MAX"
    cmd device_config put game_overlay "$MAX" mode=2,downscaleFactor=2.5

    setprop debug.hwui.renderer skiagl
}

system_tweaks() {
    setprop false debug.egl.force_msaa
    setprop false debug.egl.force_fxaa
    setprop false debug.egl.force_taa
    setprop false debug.egl.force_smaa

    setprop 3000 debug.slow_query_threshold
    setprop true debug.hwui.skip_empty_damage
    setprop true debug.hwui.capture_skp_enabled
    setprop 2 debug.hwui.capture_skp_frames

    cmd device_config put touchscreen input_drag_min_switch_speed 380
    settings put system pointer_speed 2
    settings put system pointer_acceleration 1

    settings put global window_animation_scale 0.5
    settings put global transition_animation_scale 0.5
    settings put global animator_duration_scale 0.5

    setprop debug.tracing.block_touch_buffer 1
    settings put system screen_glove_mode_enabled 1
    settings put secure touch_blocking_period 0

    settings put system touchscreen_sensitivity_mode 5
    settings put system touchscreen_threshold 8
    settings put system touchscreen_sensitivity 9
    settings put global touch.pressure.scale 0.001
    settings put system touch.pressure.scale 0.001
    settings put secure tap_duration_threshold 0.0
    settings put system touch.scroll.calibration physical
}

fps_calibration() {
    fps "$(dumpsys display | grep -Eo 'fps=[0-9]+' | cut -d= -f2 | sort -n | tail -n1)"
    [ -z "$fps" ] && fps 60

    cmd game set --fps "$fps" "$TH"
    cmd device_config put game_overlay "$TH" fps="$fps"

    cmd game set --fps "$fps" "$MAX"
    cmd device_config put game_overlay "$MAX" fps="$fps"

    frame_ns $((1000000000 / fps))
    phase_ns $((frame_ns / 4))

    setprop debug.sf.high_fps_early_gl_phase_offset_ns "$phase_ns"
    setprop debug.sf.high_fps_early_phase_offset_ns "$phase_ns"
    setprop debug.sf.high_fps_late_app_phase_offset_ns "$phase_ns"
    setprop debug.sf.high_fps_late_sf_phase_offset_ns "$phase_ns"
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
    run_game_setup
    system_tweaks
    fps_calibration
    external_exe
    sensi_calibrar
}

main >/dev/null 2>&1
