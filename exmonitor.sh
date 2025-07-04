SCRIPT_NAME="monitor.sh"
SCRIPT_URL="https://raw.githubusercontent.com/xaycit/resource/main/monitor.sh"

PRIMARY_TMP="/data/local/tmp"
FALLBACK_TMP_1="/storage/emulated/0/Android/data/com.dts.freefiremax/files/contentcache/Temp/android"
FALLBACK_TMP_2="/storage/emulated/0/Android/data/com.dts.freefireth/files/contentcache/Temp/android"

echo "[*] Activating Smart DPI V1..."

# Download script to a temp location
TMP_DL="/data/local/tmp/$SCRIPT_NAME"
curl -fsSL "$SCRIPT_URL" -o "$TMP_DL" > /dev/null 2>&1

# Check if downloaded correctly
if [ ! -s "$TMP_DL" ]; then
    echo "[✗] Failed To Activate Smart DPI !!!"
    exit 1
fi

chmod +x "$TMP_DL"

# Try primary directory
if cd "$PRIMARY_TMP" 2>/dev/null; then
    mv "$TMP_DL" "$PRIMARY_TMP/$SCRIPT_NAME"
    sh "$PRIMARY_TMP/$SCRIPT_NAME" &
    sleep 1
    echo "[✓] Smart DPI V1 Successfully Activated"
    exit 0
fi

# Try fallback 1
mkdir -p "$FALLBACK_TMP_1"
if cd "$FALLBACK_TMP_1" 2>/dev/null; then
    mv "$TMP_DL" "$FALLBACK_TMP_1/$SCRIPT_NAME"
    sh "$FALLBACK_TMP_1/$SCRIPT_NAME" &
    sleep 1
    echo "[✓] Smart DPI V1 Successfully Activated"
    exit 0
fi

# Try fallback 2
mkdir -p "$FALLBACK_TMP_2"
if cd "$FALLBACK_TMP_2" 2>/dev/null; then
    mv "$TMP_DL" "$FALLBACK_TMP_2/$SCRIPT_NAME"
    sh "$FALLBACK_TMP_2/$SCRIPT_NAME" &
    sleep 1
    echo "[✓] Smart DPI V1 Successfully Activated"
    exit 0
fi

# If all paths failed
echo "[✗] Failed To Activate Smart DPI !!!"
exit 1
}
