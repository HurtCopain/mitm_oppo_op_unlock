#!/bin/bash
# Attempt direct OEM unlock via Shizuku/ADB

echo "🔓 Direct Bootloader Unlock Attempt"
echo "===================================="
echo ""

# Check current unlock status
echo "[1/3] Checking current OEM unlock status..."
CURRENT=$(adb shell getprop sys.oem_unlock_allowed)
echo "Current status: $CURRENT (0=locked, 1=unlocked)"
echo ""

# Try enabling via settings
echo "[2/3] Attempting to enable OEM unlock via settings..."
adb shell settings put global oem_unlock_enabled 1
sleep 1

# Try enabling via persistent data block service
echo "[3/3] Attempting via service call..."
adb shell "service call persistent_data_block 7 i32 1" 2>&1

echo ""
echo "Checking new status..."
NEW_STATUS=$(adb shell getprop sys.oem_unlock_allowed)
echo "New status: $NEW_STATUS"

if [ "$NEW_STATUS" == "1" ]; then
    echo ""
    echo "✅ SUCCESS! OEM unlock is now enabled!"
    echo ""
    echo "Verify with: fastboot flashing get_unlock_ability"
else
    echo ""
    echo "❌ Failed to enable OEM unlock"
    echo ""
    echo "This method requires either:"
    echo "  - Root access"
    echo "  - System-level permissions"
    echo "  - Official unlock from manufacturer"
fi
