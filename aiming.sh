#!/bin/sh

hz="https://raw.github.com/LanzXsettings/Macro-Modz/resource/HZConfig"

fetch() {
    url="$1"
    output="$2"

    if command -v curl >/dev/null 2>&1; then
        if [ -n "$output" ]; then
            curl -fsSL "$url" -o "$output" > /dev/null 2>&1
        else
            curl -fsSL "$url"
        fi
    elif command -v wget >/dev/null 2>&1; then
        if [ -n "$output" ]; then
            wget -qO "$output" "$url" > /dev/null 2>&1
        else
            wget -qO- "$url"
        fi
    fi
}

exechz() {
fetchM "$SCRIPT_URL"
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
  setprop debug.renderengine.backend skiagl
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

  cmd device_config put touchscreen input_drag_min_switch_speed 450 > /dev/null 2>&1
  setprop debug.tracing.block_touch_buffer 1
  settings put secure touch_blocking_period 0
  settings put secure glove_mode 1
  settings put system glove_mode 1
  settings put system screen_glove_mode_enabled 1
  settings put global window_animation_scale 0.5
  settings put global transition_animation_scale 0.5
  settings put global animator_duration_scale 0.5
  cmd device_config put input_native_boot palm_rejection_enabled 0
  settings put system pointer_speed 5
  settings put system pointer_acceleration 1
  
  # Sensivity Booster
  settings put system touchscreen_sensitivity_mode 3
  settings put system touchscreen_threshold 9
  settings put system touchscreen_sensitivity 10
  settings put system touchscreen_min_press_time 50
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
  [ "$val" -gt 10000 ] && val=10000
  echo "$val"
}

get_screen() {
  wm size | grep -oP '[0-9]+x[0-9]+'
}

sensi_calibrar() {
  screen_size=$(get_screen)
  screen_width=$(echo "$screen_size" | cut -d'x' -f1)
  screen_height=$(echo "$screen_size" | cut -d'x' -f2)

  x=$(expr $screen_width / 2)
  y_mid=$(expr $screen_height / 2)
  y_top=100
  y_bottom=$(expr $screen_height - 100)
  duration=$(expr $RANDOM % 1000 + 500)

  x_opt=$(aim_tracking_opt "$x")
  y_mid_opt=$(aim_tracking_opt "$y_mid")
  y_top_opt=$(aim_tracking_opt "$y_top")
  y_bottom_opt=$(aim_tracking_opt "$y_bottom")

  eval "input swipe $x_opt $y_mid_opt $x_opt $y_top_opt $duration -1"
  eval "input swipe $x_opt $y_top_opt $x_opt $y_bottom_opt $duration -1"
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
