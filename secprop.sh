ns=$(dumpsys SurfaceFlinger | grep -i vsync | awk '/VSYNC period:/ {print $7}')
pkg="com.dts.freefireth com.dts.freefiremax"

props() {
    # SurfaceFlinger tuning
    setprop debug.sf.early.app.duration 16667
    setprop debug.sf.early.sf.duration 16667
    setprop debug.sf.earlyGl.app.duration 16667
    setprop debug.sf.earlyGl.sf.duration 16667
    setprop debug.sf.early_app_phase_offset_ns $ns
    setprop debug.sf.early_gl_app_phase_offset_ns $ns
    setprop debug.sf.early_phase_offset_ns $ns
    setprop debug.sf.high_fps.early.app.duration 16667
    setprop debug.sf.high_fps.early.sf.duration 16667
    setprop debug.sf.high_fps.earlyGl.app.duration 16667
    setprop debug.sf.high_fps.hwc.min.duration $ns
    setprop debug.sf.high_fps.late.app.duration 16667
    setprop debug.sf.high_fps.late.sf.duration 16667
    setprop debug.sf.high_fps_early_app_phase_offset_ns $ns
    setprop debug.sf.high_fps_early_cpu_app_offset_ns $ns
    setprop debug.sf.high_fps_early_gl_app_phase_offset_ns $ns
    setprop debug.sf.high_fps_early_gpu_app_offset_ns $ns
    setprop debug.sf.high_fps_early_phase_offset_ns $ns
    setprop debug.sf.high_fps_late_app_phase_offset_ns $ns
    setprop debug.sf.high_fps_late_gl_phase_offset_ns $ns
    setprop debug.sf.high_fps_late_phase_offset_ns $ns
    setprop debug.sf.high_fps_late_sf_phase_offset_ns $ns
    setprop debug.sf.phase_offset_threshold_for_next_vsync_ns $ns
    setprop debug.sf.early.display.phase_offset_ns $ns
    setprop debug.sf.early.presentation.phase_offset_ns $ns
    setprop debug.sf.high_fps.sf.max.duration 16667
    setprop debug.sf.high_sf.fps.min.duration 16667
    setprop debug.sf.high_fps.gl_ui.app_phase_offset_ns $ns
    setprop debug.sf.high_fps.gl_ui_app.duration 16667
    setprop debug.sf.max_display_buffer_acquire_time_us $ns
    setprop debug.sf.client_target_offset_ns $ns
    setprop debug.sf.display_freeze_budget_ns $ns
    setprop debug.sf.rendering_freeze.budget_ns $ns
}
props >/dev/null 2>&1

(
    # Boost-related settings
    settings put global kernel_cpu_thread_reader 5
    settings put global enhanced_cpu_responsiveness 1
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
    settings put global game_driver_opt_in_package "$pkg"
) >/dev/null 2>&1

cmdperf() {
    cmd looper_stats disable
    cmd shortcut reset-throttling
    cmd shortcut reset-all-throttling
    cmd power set-adaptive-power-saver-enabled false
    cmd thermalservice override-status 0
    cmd power set-mode 0
}
cmdperf >/dev/null 2>&1

net() {
    settings put global net.dns1 8.8.8.8
    settings put global net.dns2 8.8.4.4
    settings put global net.tcp.buffersize.default 16384
    settings put global net.tcp.buffersize.wifi 16384
    settings put global net.tcp.buffersize.umts 16384
    settings put global wifi_sleep_policy 2
    settings put global private_dns_specifier dns.google
    settings put global wifi_score_params rssi2=-95:-85:-73:-60,rssi5=-85:-82:-70:-57
    settings put global wifi_coverage_extend_feature_enabled 0
    settings put global wifi_networks_available_notification_on 0
    settings put global wifi_poor_connection_warning 0
    settings put global wifi_scan_always_enabled 0
    settings put global wifi_scan_throttle_enabled 0
    settings put global wifi_verbose_logging_enabled 0
    settings put global wifi_suspend_optimizations_enabled 1
    settings put global wifi_wakeup_enabled 0
    settings put global sysui_powerui_enabled 1
    settings put global ble_scan_always_enabled 0
}
net >/dev/null 2>&1


devopt() {
cmd power set-adaptive-power-saver-enabled false
cmd power set-fixed-performance-mode-enabled true
cmd power set-mode 0

# Override Thermal Status
cmd thermalservice override-status 0

# Restrict Google Play Services and IMS background activities
for app in com.google.android.gms com.google.android.ims; do
  cmd appops set $app RUN_IN_BACKGROUND ignore
  cmd appops set $app RUN_ANY_IN_BACKGROUND ignore
  cmd appops set $app START_FOREGROUND ignore
  cmd appops set $app INSTANT_APP_START_FOREGROUND ignore
done

}
devopt >/dev/null 2>&1
