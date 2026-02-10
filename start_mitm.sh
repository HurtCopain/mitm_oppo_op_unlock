#!/bin/bash
# Start mitmproxy with bootloader unlock bypass script

echo "======================================"
echo "  Deep Testing MITM Unlock Bypass"
echo "======================================"
echo ""
echo "Starting mitmproxy on port 8080..."
echo "Press Ctrl+C to stop"
echo ""
echo "📱 Configure your Android device:"
echo "   WiFi → Long press → Modify Network → Advanced"
echo "   Proxy: Manual"
echo "   Hostname: $(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1)"
echo "   Port: 8080"
echo ""
echo "🔐 Install CA certificate:"
echo "   Visit: http://mitm.it on your device"
echo ""
echo "======================================"
echo ""

# Get local IP address
LOCAL_IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1)

# Start mitmproxy with the bypass script
mitmweb --web-host 0.0.0.0 --web-port 8081 --listen-host 0.0.0.0 --listen-port 8080 \
    --set block_global=false \
    --set ssl_insecure=true \
    -s /home/<PATH>/apkdecomp/mitm_unlock_bypass.py

# Alternative: Use mitmdump for command-line only (no web interface)
# mitmdump --listen-host 0.0.0.0 --listen-port 8080 --set ssl_insecure=true -s /home/<PATH>/apkdecomp/mitm_unlock_bypass.py
