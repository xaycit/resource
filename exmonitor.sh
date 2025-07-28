SCRIPT_NAME="monitor.sh"
SCRIPT_URL="https://raw.githubusercontent.com/xaycit/resource/main/monitor.sh"

PRIMARY_TMP="/data/local/tmp"
FALLBACK_TMP_1="/storage/emulated/0/Android/data/com.dts.freefiremax/files/contentcache/Temp/android"
FALLBACK_TMP_2="/storage/emulated/0/Android/data/com.dts.freefireth/files/contentcache/Temp/android"

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

echo "[*] Activating Real-time Monitoring..."

# Download script to a temp location
TMP_DL="/data/local/tmp/$SCRIPT_NAME"
fetch "$SCRIPT_URL" "$TMP_DL"

# Check if downloaded correctly
if [ ! -s "$TMP_DL" ]; then
    echo "[✗] Failed To Activate Real-time Monitoring !!!"
    exit 1
fi

chmod +x "$TMP_DL"

# Try primary directory
if cd "$PRIMARY_TMP" 2>/dev/null; then
    mv "$TMP_DL" "$PRIMARY_TMP/$SCRIPT_NAME"
    sh "$PRIMARY_TMP/$SCRIPT_NAME" > /dev/null 2>&1 &
    sleep 1
    echo "[✓] Real-time Monitoring Successfully Activated"
    exit 0
fi

# Try fallback 1
mkdir -p "$FALLBACK_TMP_1"
if cd "$FALLBACK_TMP_1" 2>/dev/null; then
    mv "$TMP_DL" "$FALLBACK_TMP_1/$SCRIPT_NAME"
    sh "$FALLBACK_TMP_1/$SCRIPT_NAME" > /dev/null 2>&1 &
    sleep 1
    echo "[✓] Real-time Monitoring Successfully Activated"
    exit 0
fi

# Try fallback 2
mkdir -p "$FALLBACK_TMP_2"
if cd "$FALLBACK_TMP_2" 2>/dev/null; then
    mv "$TMP_DL" "$FALLBACK_TMP_2/$SCRIPT_NAME"
    sh "$FALLBACK_TMP_2/$SCRIPT_NAME" > /dev/null 2>&1 &
    sleep 1
    echo "[✓] Real-time Monitoring Successfully Activated"
    exit 0
fi

# If all paths failed
echo "[✗] Failed To Activate Real-time Monitoring !!!"
exit 1
}
