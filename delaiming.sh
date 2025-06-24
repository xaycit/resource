#!/bin/sh

  cmd game reset com.dts.freefireth
  cmd game reset com.dts.freefiremax
  cmd game downscale disable com.dts.freefireth
  cmd game downscale disable com.dts.freefiremax
  device_config delete game_overlay com.dts.freefireth 
  device_config delete game_overlay com.dts.freefiremax 
  dumpsys deviceidle whitelist -com.dts.freefireth> /dev/null 2>&1
  dumpsys deviceidle whitelist -com.dts.freefiremax> /dev/null 2>&1
  settings put secure long_press_timeout 350
  settings put secure multi_press_timeout 350

  cmd power set-adaptive-power-saver-enabled true
  cmd power set-fixed-performance-mode-enabled false
  cmd power set-mode 1
  cmd thermalservice override-status 1  
  cmd compile -m everything --reset com.dts.freefireth
  cmd compile -m everything --reset com.dts.freefiremax
  pkill -f dpi
