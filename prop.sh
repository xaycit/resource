#!/bin/sh

TH "com.dts.freefireth"
MAX "com.dts.freefiremax"

ns "$(dumpsys SurfaceFlinger | awk '/VSYNC period:/ {print $7}')"
[ -z "$ns" ] && ns 16666666

sf() {
    setprop debug.sf.early.app.duration 16667
    setprop debug.sf.early.sf.duration 16667
    setprop debug.sf.earlyGl.app.duration 16667
    setprop debug.sf.earlyGl.sf.duration 16667

    setprop debug.sf.early_app_phase_offset_ns "$ns"
    setprop debug.sf.early_gl_app_phase_offset_ns "$ns"
    setprop debug.sf.early_phase_offset_ns "$ns"

    setprop debug.sf.high_fps.early.app.duration 16667
    setprop debug.sf.high_fps.early.sf.duration 16667
    setprop debug.sf.high_fps.earlyGl.app.duration 16667
    setprop debug.sf.high_fps.hwc.min.duration "$ns"

    setprop debug.sf.high_fps.late.app.duration 16667
    setprop debug.sf.high_fps.late.sf.duration 16667

    setprop debug.sf.high_fps_early_app_phase_offset_ns "$ns"
    setprop debug.sf.high_fps_early_cpu_app_offset_ns "$ns"
    setprop debug.sf.high_fps_early_gl_app_phase_offset_ns "$ns"
    setprop debug.sf.high_fps_early_gpu_app_offset_ns "$ns"
    setprop debug.sf.high_fps_early_phase_offset_ns "$ns"

    setprop debug.sf.high_fps_late_app_phase_offset_ns "$ns"
    setprop debug.sf.high_fps_late_gl_app_phase_offset_ns "$ns"
    setprop debug.sf.high_fps_late_phase_offset_ns "$ns"
    setprop debug.sf.high_fps_late_sf_phase_offset_ns "$ns"

    setprop debug.sf.phase_offset_threshold_for_next_vsync_ns "$ns"
    setprop debug.sf.early.display.phase_offset_ns "$ns"
    setprop debug.sf.early.presentation.phase_offset_ns "$ns"

    setprop debug.sf.high_fps.sf.max.duration 16667
    setprop debug.sf.high_sf.fps.min.duration 16667

    setprop debug.sf.high_fps.gl_ui.app_phase_offset_ns "$ns"
    setprop debug.sf.high_fps.gl_ui_app.duration 16667

    setprop debug.sf.max_display_buffer_acquire_time_us "$ns"
    setprop debug.sf.client_target_offset_ns "$ns"
    setprop debug.sf.display_freeze_budget_ns "$ns"
    setprop debug.sf.rendering_freeze.budget_ns "$ns"

    setprop debug.sf.showfps 0
    setprop debug.sf.showcpu 0
}

ui_tune() {
    setprop debug.hwui.capture_skp_enabled false
    setprop debug.hwui.disable_scissor_opt true
    setprop debug.hwui.filter_test_overhead false
    setprop debug.hwui.fps_divisor 1
    setprop debug.hwui.level 0
    setprop debug.hwui.overdraw false
    setprop debug.hwui.profile false
    setprop debug.hwui.show_dirty_regions false
    setprop debug.hwui.show_layers_updates false
    setprop debug.hwui.show_non_rect_clip false
    setprop debug.hwui.skia_tracing_enabled false
    setprop debug.hwui.skia_use_perfetto_track_events false
    setprop debug.hwui.target_cpu_time_percent 25
    setprop debug.hwui.trace_gpu_resources false
    setprop debug.hwui.use_hint_manager true
    setprop debug.hwui.fps_divisor 0
    setprop debug.hwui.webview_overlays_enabled true
}
ui_tune >/dev/null 2>&1

render() {
    setprop debug.egl.sync 0
    setprop debug.gfx.force_async 1
    setprop debug.hwc.force_async 1
    setprop debug.sf.force_async 1

    setprop debug.hwui.renderer vulkan
    setprop debug.renderengine.backend vulkan
    setprop debug.composition.type "$(getprop debug.hwui.renderer)"
    setprop debug.composition.type2 gpu
    setprop debug.composition.pipeline.type 3
}
render >/dev/null 2>&1

power() {
    cmd looper_stats disable
    cmd power set-adaptive-power-saver-enabled false
    cmd power set-fixed-performance-mode-enabled true
    cmd power set-mode 0
    setprop debug.performance.tuning 1
    cmd thermalservice override-status 0

    settings put system high_performance_mode_on 1
    settings put system power_save_type_performance 1
    settings put global low_power 0
    settings put global low_power_sticky 0
    settings put global perftune_cpu_enabled 1
    settings put global perftune_gpu_enabled 1
    settings put global perftune_ram_enabled 1
    settings put global power_mode_refresh_rate 2
    settings put global power_mode_refresh_rate_cover 2
    settings put global gpu_driver_enabled 1
    settings put global oppo_comm_traffic_limit_speed 0
    settings put global game_driver_sphal_libraries sphal64
    settings put global background_thread_cpu_coordination true
    settings put global enhanced_graphics false
    settings put global post_install_config_epoch non_publicly_stable
    settings put global activity_starts_logging_enabled false
    settings put global game_driver_opt_in 1
    settings put global kernel_cpu_thread_reader 5
    settings put global enhanced_cpu_responsiveness 1
}
power >/dev/null 2>&1

idle() {
    dumpsys deviceidle unforce
    dumpsys deviceidle disable
    dumpsys deviceidle whitelist +"$TH"
    dumpsys deviceidle whitelist +"$MAX"
}
idle >/dev/null 2>&1

net() {
    settings put global net.dns1 8.8.8.8
    settings put global net.dns2 8.8.4.4
    settings put global private_dns_specifier dns.google

    settings put global net.tcp.buffersize.default 16384
    settings put global net.tcp.buffersize.wifi 16384
    settings put global net.tcp.buffersize.umts 16384

    settings put global wifi_sleep_policy 2
    settings put global wifi_scan_always_enabled 0
    settings put global wifi_scan_throttle_enabled 0
    settings put global wifi_verbose_logging_enabled 0
    settings put global wifi_suspend_optimizations_enabled 1
    settings put global wifi_wakeup_enabled 0
    settings put global wifi_networks_available_notification_on 0
    settings put global wifi_poor_connection_warning 0
    settings put global wifi_coverage_extend_feature_enabled 0
    settings put global sysui_powerui_enabled 1
    settings put global ble_scan_always_enabled 0
}
net >/dev/null 2>&1

game() {
    cmd game set --fps 120 "$TH"
    cmd package compile -m speed --secondary-dex "$TH"
    cmd appops set "$TH" RUN_IN_BACKGROUND
    settings put global game_driver_opt_in_package "$TH"

    cmd game set --fps 120 "$MAX"
    cmd package compile -m speed --secondary-dex "$MAX"
    cmd appops set "$MAX" RUN_IN_BACKGROUND
    settings put global game_driver_opt_in_package "$MAX"
}
game >/dev/null 2>&1

renderboost() {
    setprop debug.egl.sync 0
    setprop debug.gfx.force_async 1
    setprop debug.mdpcomp.force_async 1
    setprop debug.hwc.force_async 1
    setprop debug.sf.force_async 1
    setprop debug.force-opengl 1
    setprop debug.hwc.force_gpu_vsync 1

    setprop debug.composition.type "$(getprop debug.hwui.renderer)"
    setprop debug.composition.type2 gpu
    setprop debug.composition.pipeline.type 3
}
renderboost >/dev/null 2>&1

cmdperf() {
    cmd looper_stats disable
    cmd shortcut reset-throttling
    cmd shortcut reset-all-throttling
    cmd power set-adaptive-power-saver-enabled false
    cmd thermalservice override-status 0
    cmd power set-mode 0
}
cmdperf >/dev/null 2>&1

idleperf() {
    dumpsys deviceidle unforce
    dumpsys deviceidle disable
}
idleperf >/dev/null 2>&1

devopt() {
    cmd power set-adaptive-power-saver-enabled false
    cmd power set-fixed-performance-mode-enabled true
    cmd power set-mode 0
    settings put global GPUTUNER_SWITCH true
    cmd thermalservice override-status 0

    for app in com.google.android.gms com.google.android.ims; do
        cmd appops set "$app" RUN_IN_BACKGROUND ignore
        cmd appops set "$app" RUN_ANY_IN_BACKGROUND ignore
        cmd appops set "$app" START_FOREGROUND ignore
        cmd appops set "$app" INSTANT_APP_START_FOREGROUND ignore
    done

    setprop debug.hwui.renderer vulkan
    setprop debug.renderengine.backend vulkan

    settings put system high_performance_mode_on 1
    settings put system power_save_type_performance 1
    settings put global low_power 0
    settings put global low_power_sticky 0
}
devopt >/dev/null 2>&1
