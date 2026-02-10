#!/bin/bash
# Install mitmproxy certificate as system certificate

echo "📱 Installing mitmproxy CA as system certificate..."
echo ""

# Check for root
adb root
sleep 2
adb remount

if [ $? -ne 0 ]; then
    echo "❌ Error: Unable to remount system partition"
    echo "Your device may not have root access or system partition is read-only"
    exit 1
fi

# Get certificate hash
cd ~/.mitmproxy
HASH=$(openssl x509 -inform PEM -subject_hash_old -in mitmproxy-ca-cert.pem | head -1)

if [ -z "$HASH" ]; then
    echo "❌ Error: Could not calculate certificate hash"
    exit 1
fi

echo "Certificate hash: $HASH"

# Copy cert with proper format
cp mitmproxy-ca-cert.pem ${HASH}.0

echo "Pushing certificate to device..."
adb push ${HASH}.0 /system/etc/security/cacerts/

echo "Setting permissions..."
adb shell chmod 644 /system/etc/security/cacerts/${HASH}.0
adb shell chown root:root /system/etc/security/cacerts/${HASH}.0

echo ""
echo "✅ Certificate installed!"
echo "⚠️  Rebooting device for changes to take effect..."
echo ""
adb reboot

echo "Waiting for device to reboot..."
adb wait-for-device

echo ""
echo "✅ Done! Your device now trusts mitmproxy as a system certificate."
echo ""
echo "Next steps:"
echo "1. Start mitmproxy again: ./start_mitm.sh"
echo "2. Configure WiFi proxy on device"
echo "3. Install ORIGINAL deep.apk: adb install deep.apk"
echo "4. Run the app and click Apply!"
