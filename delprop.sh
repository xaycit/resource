#!/bin/sh

rmvv() {
    dumpsys deviceidle enable
    dumpsys deviceidle step deep
    dumpsys deviceidle force-idle
}

delbost() {
    settings delete global activity_manager_constants
    settings delete global enhanced_cpu_responsiveness
    settings delete global perftune_cpu_enabled
    settings delete global perftune_gpu_enabled
    settings delete global perftune_ram_enabled
    settings delete global power_mode_refresh_rate
    settings delete global power_mode_refresh_rate_cover
    settings delete global gpu_driver_enabled
    settings delete global background_thread_cpu_coordination
    settings delete global enhanced_graphics
    settings delete global post_install_config_epoch
    settings delete global activity_starts_logging_enabled

    cmd device_config delete gpu_options allow_growth
    cmd device_config delete gpu_options memory_fraction
    cmd device_config delete gpu_options performance_tuning
    cmd device_config delete lmkd_native thrashing_limit_critical
    cmd device_config delete restricted_max_cpus
    cmd device_config delete graphics_throttling
} 

delnet() {
    settings delete global net.dns1
    settings delete global net.dns2
    settings delete global net.tcp.buffersize.default
    settings delete global net.tcp.buffersize.wifi
    settings delete global net.tcp.buffersize.umts
    settings delete global wifi_sleep_policy
    settings delete global private_dns_specifier
    settings delete global wifi_score_params
    settings delete global wifi_coverage_extend_feature_enabled
    settings delete global wifi_networks_available_notification_on
    settings delete global wifi_poor_connection_warning
    settings delete global wifi_scan_always_enabled
    settings delete global wifi_scan_throttle_enabled
    settings delete global wifi_verbose_logging_enabled
    settings delete global wifi_suspend_optimizations_enabled
    settings delete global wifi_wakeup_enabled
    settings delete global sysui_powerui_enabled
    settings delete global ble_scan_always_enabled

    setprop debug.hwui.capture_skp_enabled ""
    setprop debug.hwui.disable_scissor_opt ""
    setprop debug.hwui.filter_test_overhead ""
    setprop debug.hwui.fps_divisor ""
    setprop debug.hwui.level ""
    setprop debug.hwui.overdraw ""
    setprop debug.hwui.profile ""
    setprop debug.hwui.show_dirty_regions ""
    setprop debug.hwui.show_layers_updates ""
    setprop debug.hwui.show_non_rect_clip ""
    setprop debug.hwui.skia_tracing_enabled ""
    setprop debug.hwui.skia_use_perfetto_track_events ""
    setprop debug.hwui.target_cpu_time_percent ""
    setprop debug.hwui.trace_gpu_resources ""
    setprop debug.hwui.use_hint_manager ""
    setprop debug.hwui.webview_overlays_enabled ""
} 

delcmd() {
    cmd power set-adaptive-power-saver-enabled true
    cmd power set-fixed-performance-mode-enabled false
    cmd power set-mode 1

    cmd thermalservice override-status 1

    for app in com.google.android.gms com.google.android.ims; do
        cmd appops set "$app" RUN_IN_BACKGROUND allow
        cmd appops set "$app" RUN_ANY_IN_BACKGROUND allow
        cmd appops set "$app" START_FOREGROUND allow
        cmd appops set "$app" INSTANT_APP_START_FOREGROUND allow
    done

    settings put global GPUTUNER_SWITCH false
    settings put system high_performance_mode_on 0
    settings put system power_save_type_performance 0

    settings put global low_power_sticky 0
    settings put global low_power 1
} 

main() {
rmvv
delnet
delbost
delcmd
}

main >/dev/null 2>&1
