#!/bin/sh

# ===== PKG =====
TH="com.dts.freefireth"
MAX="com.dts.freefiremax"

# ===== VSYNC =====
ns=$(dumpsys SurfaceFlinger | awk '/VSYNC period:/ {print $7}')
[ -z "$ns" ] && ns=16666666

# ===== SF =====
sf() {
setprop debug.sf.early.app.duration 16667
setprop debug.sf.early.sf.duration 16667
setprop debug.sf.earlyGl.app.duration 16667
setprop debug.sf.earlyGl.sf.duration 16667

setprop debug.sf.early_app_phase_offset_ns $ns
setprop debug.sf.early_gl_app_phase_offset_ns $ns
setprop debug.sf.early_phase_offset_ns $ns

setprop debug.sf.high_fps_early_app_phase_offset_ns $ns
setprop debug.sf.high_fps_early_gl_app_phase_offset_ns $ns
setprop debug.sf.high_fps_early_phase_offset_ns $ns
setprop debug.sf.high_fps_late_app_phase_offset_ns $ns
setprop debug.sf.high_fps_late_gl_phase_offset_ns $ns
setprop debug.sf.high_fps_late_phase_offset_ns $ns
setprop debug.sf.high_fps_late_sf_phase_offset_ns $ns

setprop debug.sf.force_higher_fps 1
setprop debug.sf.disable_hw_vsync true
setprop debug.sf.always_relayout true
setprop debug.sf.composition.type hwc-gpu
setprop debug.sf.use_phase_offsets_as_durations 1
}
sf >/dev/null 2>&1

# ===== RENDER =====
render() {
setprop debug.egl.sync 0
setprop debug.gfx.force_async 1
setprop debug.hwc.force_async 1
setprop debug.sf.force_async 1

setprop debug.hwui.renderer vulkan
setprop debug.renderengine.backend vulkan
}
render >/dev/null 2>&1

# ===== POWER =====
power() {
cmd looper_stats disable
cmd power set-adaptive-power-saver-enabled false
cmd power set-fixed-performance-mode-enabled true
cmd power set-mode 0
cmd thermalservice override-status 0

settings put system high_performance_mode_on 1
settings put system power_save_type_performance 1
settings put global low_power 0
settings put global low_power_sticky 0
}
power >/dev/null 2>&1

# ===== IDLE =====
idle() {
dumpsys deviceidle unforce
dumpsys deviceidle disable
dumpsys deviceidle whitelist +$TH
dumpsys deviceidle whitelist +$MAX
}
idle >/dev/null 2>&1

# ===== NET =====
net() {
settings put global net.dns1 8.8.8.8
settings put global net.dns2 8.8.4.4
settings put global private_dns_specifier dns.google

settings put global wifi_sleep_policy 2
settings put global wifi_scan_always_enabled 0
settings put global wifi_scan_throttle_enabled 0
settings put global wifi_verbose_logging_enabled 0
settings put global wifi_wakeup_enabled 0
}
net >/dev/null 2>&1

# ===== GAME =====
game() {
# TH
cmd game set --fps 120 $TH
cmd package compile -m speed --secondary-dex $TH
cmd appops set $TH RUN_IN_BACKGROUND
settings put global game_driver_opt_in_package $TH

# MAX
cmd game set --fps 120 $MAX
cmd package compile -m speed --secondary-dex $MAX
cmd appops set $MAX RUN_IN_BACKGROUND
settings put global game_driver_opt_in_package $MAX
}
game >/dev/null 2>&1    settings put global perftune_cpu_enabled 1
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
    settings put global game_driver_opt_in_package com.dts.freefireth
    settings put global game_driver_opt_in_package com.dts.freefiremax
) >/dev/null 2>&1

renderboost() {
#async
setprop debug.egl.sync 0
setprop debug.gfx.force_async 1
setprop debug.mdpcomp.force_async 1 
setprop debug.hwc.force_async 1
setprop debug.sf.force_async 1
setprop debug.force-opengl 1
setprop debug.hwc.force_gpu_vsync 1

#renderer
setprop debug.composition.type $(getprop debug.hwui.renderer)
setprop debug.composition.type2 gpu
setprop debug.composition.pipeline.type 3
}
renderboost > /dev/null 2>&1

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
    settings put global wifi_sleep_policy 2
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

# Set Vulkan as the default renderer
setprop debug.hwui.renderer vulkan
setprop debug.renderengine.backend vulkan

# Enable High-Performance Mode
settings put system high_performance_mode_on 1
settings put system power_save_type_performance 1

# Disable Low Power Mode
settings put global low_power_sticky 0
settings put global low_power 0
}
devopt >/dev/null 2>&1
