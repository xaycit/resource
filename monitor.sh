#!/system/bin/sh

INTERVAL=5

get_cpu_usage() {
    CPU=($(head -n 1 /proc/stat))
    unset CPU[0]
    IDLE=${CPU[3]}
    TOTAL=0
    for VALUE in "${CPU[@]}"; do
        TOTAL=$((TOTAL + VALUE))
    done

    if [ -n "$PREV_TOTAL" ]; then
        DIFF_IDLE=$((IDLE - PREV_IDLE))
        DIFF_TOTAL=$((TOTAL - PREV_TOTAL))
        CPU_USAGE=$((100 * (DIFF_TOTAL - DIFF_IDLE) / DIFF_TOTAL))
    else
        CPU_USAGE=0
    fi

    PREV_TOTAL=$TOTAL
    PREV_IDLE=$IDLE
}

while true; do
    get_cpu_usage

    CUR_HZ_PATH="/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq"
    if [ -f "$CUR_HZ_PATH" ]; then
        RAW_HZ=$(cat "$CUR_HZ_PATH" 2>/dev/null)
        CUR_HZ=$((RAW_HZ / 1000))
        ENCH_HZ=$((CUR_HZ + 150))
    else
        CUR_HZ=0
        ENCH_HZ="Unavailable"
    fi

    MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    MEM_FREE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    MEM_USED_MB=$(((MEM_TOTAL - MEM_FREE) / 1024))

    PROC_COUNT=$(ls /proc | grep -E '^[0-9]+$' | wc -l)

    MSG="CPU:${CPU_USAGE}% Freq:${CUR_HZ}MHz→${ENCH_HZ}MHz RAM:${MEM_USED_MB}MB Proc:${PROC_COUNT}"

    cmd notification post -S bigtext -t "Real-Time Monitoring" monitor "$MSG" > /dev/null 2>&1

    sleep $INTERVAL
done
