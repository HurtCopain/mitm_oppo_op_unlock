#!/bin/bash
# Install mitmproxy certificate using Shizuku privileges

echo "📜 Installing mitmproxy CA certificate via Shizuku..."
echo ""
echo "Prerequisites:"
echo "  - Shizuku app installed and running"
echo "  - Shizuku service started via ADB"
echo ""

# Check if Shizuku is running
SHIZUKU_RUNNING=$(adb shell "ps -A | grep shizuku")
if [ -z "$SHIZUKU_RUNNING" ]; then
    echo "❌ Shizuku not running!"
    echo ""
    echo "Start Shizuku with:"
    echo "  adb shell sh /sdcard/Android/data/moe.shizuku.privileged.api/start.sh"
    exit 1
fi

echo "✅ Shizuku is running"
echo ""

# Get certificate hash
cd ~/.mitmproxy
HASH=$(openssl x509 -inform PEM -subject_hash_old -in mitmproxy-ca-cert.pem | head -1)
echo "Certificate hash: $HASH"

# Copy cert with proper format
cp mitmproxy-ca-cert.pem ${HASH}.0

# Push to device temp location
adb push ${HASH}.0 /sdcard/Download/${HASH}.0

echo ""
echo "Certificate pushed to device"
echo ""
echo "⚠️ MANUAL STEP REQUIRED:"
echo "1. Install 'System Certificate Installer' or 'Certificate Installer' app"
echo "2. Grant it Shizuku permission"
echo "3. Use it to install: /sdcard/Download/${HASH}.0"
echo ""
echo "Or try using Shizuku API directly with termux..."
