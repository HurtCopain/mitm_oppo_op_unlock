#!/bin/bash
# Attach Frida to already-running Deep Testing app

echo "========================================"
echo "  Frida SSL Pinning Bypass (Attach)"
echo "========================================"
echo ""

echo "📱 MANUAL STEPS:"
echo "1. Open the Deep Testing app on your device"
echo "2. Don't click anything yet!"
echo "3. Press Enter here when the app is open..."
read -p ""

echo ""
echo "🔍 Looking for Deep Testing process..."

# Get PID of the app
PID=$(adb shell "ps -A | grep coloros.deeptesting" | awk '{print $2}')

if [ -z "$PID" ]; then
    echo "❌ App not running!"
    echo ""
    echo "Trying to find any related process..."
    adb shell "ps -A | grep -i deep"
    echo ""
    echo "Please make sure the app is open and try again."
    exit 1
fi

echo "✅ Found app (PID: $PID)"
echo "🔌 Attaching Frida to PID $PID..."
echo ""
echo "Once you see 'SSL Pinning Bypass Complete', go click 'Apply' in the app!"
echo "Watch for bypass messages below and in mitmproxy!"
echo ""
echo "Press Ctrl+C to stop"
echo "========================================"
echo ""

# Attach to running process by PID
frida -U -p $PID -l ssl-pinning-bypass.js
