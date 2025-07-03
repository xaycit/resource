#!/bin/sh
  hz="https://raw.github.com/LanzXsettings/Macro-Modz/resource/delHZConfig"

  exechz() {
  sh -c "$(curl -fsSL "$hz")" > /dev/null 2>&1
  }
  exechz
  main () {
  cmd game reset com.dts.freefireth
  cmd game reset com.dts.freefiremax
  cmd game downscale disable com.dts.freefireth
  cmd game downscale disable com.dts.freefiremax
  device_config delete game_overlay com.dts.freefireth 
  device_config delete game_overlay com.dts.freefiremax 
  dumpsys deviceidle whitelist -com.dts.freefireth> /dev/null 2>&1
  dumpsys deviceidle whitelist -com.dts.freefiremax> /dev/null 2>&1
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
  settings delete secure touch_blocking_period
  settings delete secure glove_mode
  settings delete system glove_mode
  pkill -f dpi
}
main > /dev/null 2>&1
