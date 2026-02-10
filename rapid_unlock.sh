#!/bin/bash
# Rapid-fire unlock commands for auto-rebooting engineering bootloader

echo "🚀 Rapid Engineering Bootloader Unlock"
echo "======================================="
echo ""
echo "Preparing to send commands instantly..."
echo ""

# Reboot to bootloader
adb reboot bootloader
sleep 3

echo "Triggering engineering mode with rapid command injection..."
echo ""

# Enter engineering mode and IMMEDIATELY spam unlock commands
(
  sleep 0.5  # Small delay for bootloader to enter eng mode
  fastboot oem disable-oplus-verity &
  fastboot oem disable-verity &
  fastboot oem oplus-unlock &
  fastboot flashing unlock_critical &
  fastboot flashing unlock &
  fastboot oem unlock-go &
  wait
) &

# Trigger engineering mode
fastboot oem reboot-engineering

sleep 5

echo ""
echo "Commands sent! Checking result..."
echo ""

# Check if it worked
adb wait-for-device
sleep 2
adb reboot bootloader
sleep 3

fastboot getvar unlocked
fastboot getvar oplus-unlocked

echo ""
echo "If unlocked=yes, SUCCESS! Otherwise try method 2..."
