#!/bin/bash
# Start mitmproxy with aggressive SSL bypass options

echo "======================================"
echo "  Deep Testing MITM (Aggressive SSL)"
echo "======================================"
echo ""
echo "Starting mitmproxy with SSL bypass..."
echo "Port: 8080"
echo "Web UI: http://localhost:8081"
echo ""

LOCAL_IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1)
echo "Configure device proxy to: $LOCAL_IP:8080"
echo ""

# Use mitmdump with aggressive SSL options
mitmdump --listen-host 0.0.0.0 --listen-port 8080 \
    --set block_global=false \
    --set ssl_insecure=true \
    --ssl-insecure \
    --set upstream_cert=false \
    --anticache \
    -s /home/<PATH>/apkdecomp/mitm_unlock_bypass.py
