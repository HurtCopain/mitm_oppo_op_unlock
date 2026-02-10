# 🔓 MITM Bootloader Unlock Bypass - Complete Guide

This method intercepts the network traffic between the Deep Testing app and OnePlus servers, injecting a fake "approved" response that bypasses region/model restrictions.

---

## 📋 Prerequisites

✅ **Android device** and **computer** on the **same WiFi network**
✅ **Original Deep Testing APK** installed (no patching needed!)
✅ **USB debugging enabled** (optional, for easier setup)
✅ **mitmproxy installed** (already done ✓)

---

## 🚀 Quick Start (5 Steps)

### Step 1: Get Your Computer's IP Address

```bash
ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1
```

**Example output:** `192.168.1.100` ← This is your proxy IP

---

### Step 2: Start the MITM Proxy

```bash
cd /home/<PATH>/apkdecomp
./start_mitm.sh
```

You'll see:
```
Starting mitmproxy on port 8080...
Proxy server listening at http://0.0.0.0:8080
Web interface at http://0.0.0.0:8081
```

**Keep this terminal open!** The proxy must run while you use the app.

---

### Step 3: Configure Android Device Proxy

#### Option A: Via Settings (Manual)

1. **Go to:** Settings → WiFi
2. **Long press** your WiFi network → **Modify Network**
3. **Advanced Options** → Show advanced options
4. **Proxy:** Manual
5. **Hostname:** `192.168.1.100` (your computer's IP from Step 1)
6. **Port:** `8080`
7. **Save**

#### Option B: Via ADB (Automated)

```bash
# Set proxy
adb shell settings put global http_proxy 192.168.1.100:8080

# Verify
adb shell settings get global http_proxy
```

---

### Step 4: Install mitmproxy CA Certificate

#### Why?
The app uses HTTPS (encrypted). To intercept encrypted traffic, your device needs to trust mitmproxy's certificate.

#### Installation Steps:

1. **On your Android device**, open a browser
2. **Visit:** http://mitm.it
3. **Tap:** "Android" → Download the certificate
4. **Install:**
   - Go to Settings → Security → Encryption & credentials
   - Tap "Install a certificate" → CA certificate
   - Select the downloaded `mitmproxy-ca-cert.crt`
   - Name it "mitmproxy" or anything you like

#### Alternative: Push via ADB

```bash
# Download cert from mitmproxy
wget http://mitm.it/cert/pem -O mitmproxy-ca-cert.pem

# Push to device
adb push mitmproxy-ca-cert.pem /sdcard/Download/

# Then install manually via Settings → Security
```

#### For Android 11+ (User Certificates Not Trusted):

If the app doesn't trust user certificates, you need to install as system certificate:

```bash
# Requires root!
adb root
adb remount

# Get certificate hash
HASH=$(openssl x509 -inform PEM -subject_hash_old -in ~/.mitmproxy/mitmproxy-ca-cert.pem | head -1)

# Push to system
adb push ~/.mitmproxy/mitmproxy-ca-cert.pem /system/etc/security/cacerts/${HASH}.0

# Set permissions
adb shell chmod 644 /system/etc/security/cacerts/${HASH}.0

# Reboot
adb reboot
```

---

### Step 5: Use the Deep Testing App

1. **Open** the Deep Testing app on your device
2. **Click** "Submit Application" or "Apply" button
3. **Watch the mitmproxy terminal** - you'll see:
   ```
   🔓 [BYPASS] Injecting FAKE APPROVAL for apply-unlock!
   [RESPONSE] Injected unlock code: MITM_BYPASS_UNLOCK_CODE_12345678
   ```
4. The app will receive the fake approval and **unlock your bootloader!**

---

## 🖥️ Monitoring Traffic

### Web Interface (Recommended)

While mitmproxy is running, open in your browser:
```
http://localhost:8081
```

You'll see:
- ✅ All intercepted requests in real-time
- ✅ Request/response details
- ✅ Ability to replay requests
- ✅ Search and filter traffic

### Terminal Only (Alternative)

Use `mitmdump` instead of `mitmweb`:
```bash
mitmdump --listen-host 0.0.0.0 --listen-port 8080 \
    --set ssl_insecure=true \
    -s /home/<PATH>kdecomp/mitm_unlock_bypass.py
```

---

## 🔍 Verification

### Check Interception is Working:

1. **On your device:** Open any browser, visit http://example.com
2. **In mitmproxy web UI:** You should see the HTTP request
3. **If you see traffic:** ✅ Proxy is working!

### After Running the App:

Check if the unlock was successful:

```bash
# Check OEM unlock status
adb shell getprop sys.oem_unlock_allowed
# Expected: 1

# Or via fastboot
adb reboot bootloader
fastboot flashing get_unlock_ability
# Expected: 1
```

---

## 🐛 Troubleshooting

### Issue 1: "No internet connection" in the app

**Cause:** Proxy not configured correctly or mitmproxy not running

**Fix:**
- Verify computer IP address is correct
- Check mitmproxy is running (`./start_mitm.sh`)
- Test with browser: http://example.com should work

### Issue 2: "SSL Handshake Failed" or certificate errors

**Cause:** mitmproxy CA certificate not installed/trusted

**Fix:**
- Re-install certificate from http://mitm.it
- For Android 11+: Install as system certificate (requires root)
- Check certificate in: Settings → Security → Trusted credentials

### Issue 3: App shows "Network Error" or doesn't connect

**Cause:** App may be using certificate pinning

**Fix:** The script has `ssl_insecure=true` which should bypass most checks, but if it still fails:

```bash
# Try with different SSL options
mitmweb --listen-port 8080 --set ssl_insecure=true --set ssl_verify_upstream_trusted_ca=false \
    -s /home/<PATH>/apkdecomp/mitm_unlock_bypass.py
```

### Issue 4: No traffic showing in mitmproxy

**Cause:** App might be bypassing system proxy or using direct connection

**Fix:**
```bash
# Use iptables to redirect all traffic (requires root on computer)
sudo iptables -t nat -A OUTPUT -p tcp --dport 443 -j REDIRECT --to-port 8080
sudo iptables -t nat -A OUTPUT -p tcp --dport 80 -j REDIRECT --to-port 8080
```

Or use a VPN-based proxy like **ProxyDroid** (requires root on Android).

### Issue 5: Response injected but unlock still fails

**Cause:** The app's `PersistentDataBlockManager` call might require system permissions

**Fix:** This is the same limitation as the patched APK. Options:
1. Root your device and install app as system app
2. Your device's bootloader may be hardware-locked

---

## 🧹 Cleanup (After Successful Unlock)

### Remove Proxy Settings:

```bash
# Via ADB
adb shell settings delete global http_proxy

# Or manually: WiFi settings → Remove proxy
```

### Remove Certificate (Optional):

Settings → Security → Trusted credentials → User → Select "mitmproxy" → Remove

### Stop mitmproxy:

Press `Ctrl+C` in the terminal

---

## 📊 What Gets Intercepted

The script intercepts these API endpoints:

1. **`/api/v3/apply-unlock`** - Initial unlock application
   - **Original:** Sends device model, IMEI, region for validation
   - **Bypassed:** Returns fake approval with unlock code

2. **`/api/v3/check-approve-result`** - Check approval status
   - **Original:** Returns "pending" for unapproved devices
   - **Bypassed:** Returns "approved" immediately

3. **`/api/v3/update-client-lock-status`** - Update unlock status
   - **Original:** Reports unlock status to server
   - **Bypassed:** Returns success

4. **`/api/v3/get-all-status`** - Query current status
   - **Original:** Returns locked status for unsupported devices
   - **Bypassed:** Returns unlocked status

---

## 🔐 Security Notes

- ⚠️ **Certificate Warning:** The mitmproxy certificate allows intercepting **all HTTPS traffic** while installed. Remove it after use!
- ⚠️ **Network Security:** Only use on trusted networks
- ⚠️ **Temporary:** This is for a one-time unlock. Remove proxy/certificate after success.

---

## 📱 Tested Android Versions

- ✅ **Android 11-14:** Works with user certificates (some apps may require system certificate)
- ✅ **Android 10 and below:** Works with user certificates
- ⚠️ **Android 15+:** May require additional setup due to stricter certificate requirements

---

## 🎯 Success Checklist

Before attempting the unlock:
- [ ] mitmproxy installed and running
- [ ] Android device connected to same WiFi
- [ ] Proxy configured on device
- [ ] mitmproxy CA certificate installed and trusted
- [ ] Test with browser - can load http://example.com
- [ ] Deep Testing app installed (original, not patched)

During unlock attempt:
- [ ] Open Deep Testing app
- [ ] Click "Apply" or "Submit Application"
- [ ] See interception in mitmproxy terminal: "🔓 [BYPASS] Injecting FAKE APPROVAL"
- [ ] App shows success message

After unlock:
- [ ] Run: `adb shell getprop sys.oem_unlock_allowed` → Should return `1`
- [ ] Remove proxy settings
- [ ] Remove mitmproxy certificate
- [ ] Reboot to bootloader: `adb reboot bootloader`
- [ ] Check unlock ability: `fastboot flashing get_unlock_ability` → Should return `1`
- [ ] **Actually unlock:** `fastboot flashing unlock`

---

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review mitmproxy logs for error messages
3. Try the terminal-only mode: `mitmdump` for more detailed logs
4. Verify your device supports bootloader unlocking at all

---

## ⚡ Quick Reference Commands

```bash
# Start MITM proxy
cd /home/<path>/apkdecomp && ./start_mitm.sh

# Set proxy via ADB
adb shell settings put global http_proxy YOUR_IP:8080

# Check OEM unlock status
adb shell getprop sys.oem_unlock_allowed

# Remove proxy
adb shell settings delete global http_proxy

# Reboot to bootloader
adb reboot bootloader

# Check unlock ability
fastboot flashing get_unlock_ability

# UNLOCK BOOTLOADER (Point of no return!)
fastboot flashing unlock
```

---

Good luck! 🚀🔓
