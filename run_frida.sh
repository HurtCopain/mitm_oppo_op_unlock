#!/bin/bash
# Run Frida to bypass SSL pinning in Deep Testing app

echo "========================================"
echo "  Frida SSL Pinning Bypass"
echo "========================================"
echo ""

# Push frida-server to device
echo "[1/3] Pushing frida-server to device..."
adb push frida-server /data/local/tmp/ 2>/dev/null
adb shell chmod 755 /data/local/tmp/frida-server 2>/dev/null

# Start frida-server if not running
echo "[2/3] Ensuring frida-server is running..."
FRIDA_RUNNING=$(adb shell "ps -A | grep frida-server")
if [ -z "$FRIDA_RUNNING" ]; then
    echo "Starting frida-server..."
    adb shell "/data/local/tmp/frida-server &" &
    sleep 3
else
    echo "✅ frida-server already running"
fi

# Check if app is installed
echo "[3/3] Checking for Deep Testing app..."
APP_INSTALLED=$(adb shell pm list packages | grep com.coloros.deeptesting)

if [ -z "$APP_INSTALLED" ]; then
    echo "❌ Deep Testing app not found!"
    echo "Installing original deep.apk..."
    adb install deep.apk
fi

echo ""
echo "✅ Ready to launch!"
echo "📱 The app will start with SSL pinning disabled"
echo "🔓 Click 'Apply' in the app - mitmproxy will intercept!"
echo ""
echo "Press Ctrl+C to stop"
echo "========================================"
echo ""

# Run frida with SSL pinning bypass (spawn the app)
frida -U -f com.coloros.deeptesting -l ssl-pinning-bypass.js
