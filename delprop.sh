#!/bin/sh

rmvv() {
    # Device Idle
    dumpsys deviceidle enable
    dumpsys deviceidle step deep
    dumpsys deviceidle force-idle
    } >/dev/null 2>&1

    # Clean performance & boost settings
    {
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
    } >/dev/null 2>&1

    # Net settings cleanup
    {
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
    } >/dev/null 2>&1

{
# Enable Adaptive Power Saver and disable Fixed Performance Mode
cmd power set-adaptive-power-saver-enabled true
cmd power set-fixed-performance-mode-enabled false
cmd power set-mode 1

# Override Thermal Status to 1
cmd thermalservice override-status 1

# Allow Google Play Services and IMS background activities
for app in com.google.android.gms com.google.android.ims; do
  cmd appops set $app RUN_IN_BACKGROUND allow
  cmd appops set $app RUN_ANY_IN_BACKGROUND allow
  cmd appops set $app START_FOREGROUND allow
  cmd appops set $app INSTANT_APP_START_FOREGROUND allow
done

# Disable High-Performance Mode
settings put system high_performance_mode_on 0
settings put system power_save_type_performance 0

# Enable Low Power Mode
settings put global low_power_sticky 0
settings put global low_power 1
} >/dev/null 2>&1
