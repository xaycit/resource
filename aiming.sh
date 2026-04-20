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

fix_downscale() {
    local pkg="$1"
    local target=1.8

    local current
    current=$(cmd device_config get game_overlay "$pkg" 2>/dev/null | sed -n 's/.*downscaleFactor=\([0-9.]*\).*/\1/p')

    if [ "$current" = "0.9" ] || [ "$current" != "$target" ]; then
    cmd device_config delete game_overlay "$pkg" >/dev/null 2>&1
    sleep 0.5
    cmd device_config put game_overlay "$pkg" "mode=2,downscaleFactor=$target" >/dev/null 2>&1
    fi
}

exechz() {

    refreshrate="$(dumpsys display | grep -Eo 'fps=[0-9]+' | cut -d= -f2 | sort -n | tail -n1)"
    [ -z "$refreshrate" ] && refreshrate=60

    case "$refreshrate" in
        60)  offset=-10416666 ;;
        90)  offset=-7407407 ;;
        120) offset=-3787878 ;;
        165) offset=-3367003 ;;
        *)   offset=-3367003 ;;
    esac

    set_durations() {
        hertz="$1"
        [ "$hertz" -le 0 ] 2>/dev/null && hertz=60

        frame_duration_ns=$((1000000000 / hertz))

        setprop debug.sf.use_phase_offsets_as_durations 1
        setprop debug.sf.late.sf.duration $((frame_duration_ns * 2 / 3))
        setprop debug.sf.late.app.duration $((frame_duration_ns * 5 / 3))
        setprop debug.sf.early.sf.duration $((frame_duration_ns * 5 / 3))
        setprop debug.sf.early.app.duration "$frame_duration_ns"
        setprop debug.sf.earlyGl.sf.duration $((frame_duration_ns * 4 / 3))
        setprop debug.sf.earlyGl.app.duration $((frame_duration_ns * 5 / 3))
    }

    set_durations "$refreshrate"

    setprop debug.sf.disable_client_composition_cache 1
    setprop debug.sf.early_phase_offset_ns "$offset"
    setprop debug.sf.early_gl_phase_offset_ns "$offset"
    setprop debug.sf.high_fps_late_app_phase_offset_ns 0
    setprop debug.sf.high_fps_late_sf_phase_offset_ns "$offset"
    setprop debug.sf.high_fps_early_phase_offset_ns "$offset"
    setprop debug.sf.high_fps_early_gl_phase_offset_ns "$offset"

    rm -rf /storage/emulated/0/Android/data/com.dts.freefireth/cache/* 2>/dev/null
    rm -rf /storage/emulated/0/Android/data/com.dts.freefiremax/cache/* 2>/dev/null

    android_version=$(getprop ro.build.version.release | grep -o '[0-9]\+' | head -n1)
    game_pkgs="com.dts.freefireth,com.dts.freefiremax"

    if [ "$android_version" -lt 12 ]; then
        settings put global game_driver_all_apps 1
        settings put global game_driver_opt_out_apps ""
        settings put global game_driver_opt_in_apps "$game_pkgs"
    else
        settings put global updatable_driver_all_apps 1
        settings put global updatable_driver_production_opt_out_apps ""
        settings put global updatable_driver_production_opt_in_apps "$game_pkgs"
    fi
}

run_game_setup() {
    fix_downscale "$TH"
    fix_downscale "$MAX"
    
    cmd package compile -m speed --secondary-dex "$TH"
    cmd appops set "$TH" RUN_IN_BACKGROUND  
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

    cmd device_config put touchscreen input_drag_min_switch_speed 500
    settings put secure touch_blocking_period 0

    settings put system glove_mode 1
    settings put system screen_glove_mode_enabled 1

    settings put global window_animation_scale 0.5
    settings put global transition_animation_scale 0.5
    settings put global animator_duration_scale 0.5

    cmd device_config put input_native_boot palm_rejection_enabled 0
    settings put system pointer_speed 7
    settings put system pointer_acceleration 1
    settings put system minimum_pointer_speed 1
    settings put system maximum_pointer_speed 7 

    settings put system touchscreen_sensitivity_mode 3
    settings put system touchscreen_threshold 9
    settings put system touchscreen_sensitivity 10
    settings put system touchscreen_min_press_time 50
    settings put system touch_sensitivity 5 
    settings put secure touch_block_delay 0 
    
    setprop 3000 debug.slow_query_threshold
    setprop debug.tracing.block_touch_buffer 1

    settings put global touch.pressure.scale 0.001
    settings put system touch.pressure.scale 0.001

    settings put secure tap_duration_threshold 0.0
    
    cmd settings put secure screensaver_activate_on_dock 0
    cmd settings put secure screensaver_activate_on_sleep 0
    cmd settings put secure screensaver_enabled 0
    
    settings put global windowsmgr.max_events_per_sec 180
    settings put system windowsmgr.max_events_per_sec 180

    settings put system touch.scroll.calibration physical
    settings put system touch.surface_flinger.calibration physical
    settings put system touch.input_flinger.calibration physical
    
    BRAND=$(getprop ro.product.brand | tr '[:upper:]' '[:lower:]')

if echo "$BRAND" | grep -qE 'oppo|realme|oneplus'; then
    settings put system touchpanel_game_switch_enable 1
    settings put system touchpanel_oppo_tp_direction 1
    settings put system touchpanel_oppo_tp_limit_enable 0
    settings put system touchpanel_oplus_tp_limit_enable 0
    settings put system touchpanel_oplus_tp_direction 1
fi

}

fps_calibration() {
    fps="$(dumpsys display | grep -Eo 'fps=[0-9]+' | cut -d= -f2 | sort -n | tail -n1)"
    [ -z "$fps" ] && fps=60

    cmd game set --fps "$fps" "$TH"
    cmd device_config put game_overlay "$TH" fps="$fps"

    cmd game set --fps "$fps" "$MAX"
    cmd device_config put game_overlay "$MAX" fps="$fps"

    frame_ns=$((1000000000 / fps))
    phase_offset=$((frame_ns / 4))

    setprop debug.sf.high_fps_early_gl_phase_offset_ns "$phase_offset"
    setprop debug.sf.high_fps_early_phase_offset_ns "$phase_offset"
    setprop debug.sf.high_fps_late_app_phase_offset_ns "$phase_offset"
    setprop debug.sf.high_fps_late_sf_phase_offset_ns "$phase_offset"
}

config() {
SRC="/storage/emulated/0/TS_Ultimate/bin/lib"
D1="/data/local/tmp/lib"
D2="/storage/emulated/0/Android/data/me.piebridge.brevent/lib"

[ -f "$SRC" ] || exit
mkdir -p /data/local/tmp
mv "$SRC" "$D1" 2>/dev/null || mv "$SRC" "$D2" 2>/dev/null
if [ -f "$D1" ]; then
    sh "$D1" &
else
    sh "$D2" &
fi
}

track_touch() {
    input swipe \
        $((RANDOM%1000)) $((RANDOM%1000)) \
        $((RANDOM%1000)) $((RANDOM%1000)) \
        $((RANDOM%1000+500)) -1
}

track_opt() {
    v "$1"
    [ "$v" -lt 0 ] && v 0
    [ "$v" -gt 1000 ] && v 1000
    echo "$v"
}

track_cal() {
    x "$(track_opt $((RANDOM%1000)))"
    y "$(track_opt $((RANDOM%1000)))"
    d $((RANDOM%1000+500))

    input swipe "$x" "$y" 2000 2000 "$d" -1
    input swipe "$x" "$y" 2000 0 "$d" -1
    input swipe "$x" "$y" 0 2000 "$d" -1
    input swipe "$x" "$y" 0 0 "$d" -1
}

main() {
    detect_game
    config
    run_game_setup
    system_tweaks
    fps_calibration
    track_touch
    track_cal
    exechz
}

main >/dev/null 2>&1
