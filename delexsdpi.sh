echo "[*] Deactivating Smart DPI V1..."

rm -f /data/local/tmp/sdpi.sh
rm -f /tmp/sdpi.sh
rm -f /storage/emulated/0/Android/data/com.dts.freefiremax/files/contentcache/Temp/android/sdpi.sh
rm -f /storage/emulated/0/Android/data/com.dts.freefireth/files/contentcache/Temp/android/sdpi.sh
pkill -f sdpi.sh

echo "[✓] Smart DPI V1 Successfully Deactivated"
