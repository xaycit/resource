#!/bin/sh

# ===== PKG =====
TH="com.dts.freefireth"
MAX="com.dts.freefiremax"

# ===== GAME SETUP =====
run_game_setup() {
  # TH
  cmd game downscale 2.5 $TH
  cmd device_config put game_overlay $TH mode=2,downscaleFactor=2.5

  # MAX
  cmd game downscale 2.5 $MAX
  cmd device_config put game_overlay $MAX mode=2,downscaleFactor=2.5

  setprop debug.hwui.renderer skiagl
}

# ===== SYSTEM =====
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

  # Sensitivity
  settings put system touchscreen_sensitivity_mode 3
  settings put system touchscreen_threshold 8
  settings put system touchscreen_sensitivity 9
}

# ===== FPS =====
fps_calibration() {
  fps="$(dumpsys display | grep -Eo 'fps=[0-9]+' | cut -d= -f2 | sort -n | tail -n1)"
  [ -z "$fps" ] && fps=60

  cmd game set --fps "$fps" $TH
  cmd device_config put game_overlay $TH fps="$fps"

  cmd game set --fps "$fps" $MAX
  cmd device_config put game_overlay $MAX fps="$fps"

  frame_ns=$((1000000000 / fps))
  phase_ns=$((frame_ns / 4))

  setprop debug.sf.high_fps_early_gl_phase_offset_ns $phase_ns
  setprop debug.sf.high_fps_early_phase_offset_ns $phase_ns
  setprop debug.sf.high_fps_late_app_phase_offset_ns $phase_ns
  setprop debug.sf.high_fps_late_sf_phase_offset_ns $phase_ns
}

# ===== RANDOM TOUCH =====
external_exe() {
  input swipe $((RANDOM%1000)) $((RANDOM%1000)) \
              $((RANDOM%1000)) $((RANDOM%1000)) \
              $((RANDOM%1000+500)) -1
}

# ===== AIM LIMIT =====
aim_tracking_opt() {
  v="$1"
  [ "$v" -lt 0 ] && v=0
  [ "$v" -gt 1000 ] && v=1000
  echo "$v"
}

# ===== SENSI =====
sensi_calibrar() {
  x=$(aim_tracking_opt $((RANDOM%1000)))
  y=$(aim_tracking_opt $((RANDOM%1000)))
  d=$((RANDOM%1000+500))

  input swipe "$x" "$y" 2000 2000 "$d" -1
  input swipe "$x" "$y" 2000 0 "$d" -1
  input swipe "$x" "$y" 0 2000 "$d" -1
  input swipe "$x" "$y" 0 0 "$d" -1
}

# ===== MAIN =====
main() {
  run_game_setup
  system_tweaks
  fps_calibration
  external_exe
  sensi_calibrar
}

main > /dev/null 2>&1  duration=$(expr $RANDOM % 1000 + 500)
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
}
main > /dev/null 2>&1
