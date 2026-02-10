/**
 * Universal SSL Pinning Bypass for Android
 * Bypasses certificate pinning in the Deep Testing app
 */

console.log("[*] SSL Pinning Bypass Script Loaded");

// Hook SSLContext
Java.perform(function() {
    console.log("[*] Starting SSL Pinning Bypass...");

    try {
        // Hook SSLContext.init() to accept all certificates
        var SSLContext = Java.use('javax.net.ssl.SSLContext');
        SSLContext.init.overload('[Ljavax.net.ssl.KeyManager;', '[Ljavax.net.ssl.TrustManager;', 'java.security.SecureRandom').implementation = function(keyManager, trustManager, secureRandom) {
            console.log('[+] SSLContext.init() called');
            console.log('[+] Overriding TrustManager to accept all certificates');

            var TrustManager = Java.use('javax.net.ssl.X509TrustManager');
            var EmptyTrustManager = Java.registerClass({
                name: 'com.sensepost.test.EmptyTrustManager',
                implements: [TrustManager],
                methods: {
                    checkClientTrusted: function(chain, authType) {},
                    checkServerTrusted: function(chain, authType) {},
                    getAcceptedIssuers: function() {
                        return [];
                    }
                }
            });

            var TrustManagers = [EmptyTrustManager.$new()];
            this.init.overload('[Ljavax.net.ssl.KeyManager;', '[Ljavax.net.ssl.TrustManager;', 'java.security.SecureRandom').call(this, keyManager, TrustManagers, secureRandom);
            console.log('[+] SSLContext initialized with custom TrustManager');
        };
        console.log('[+] Hooked SSLContext.init()');
    } catch(e) {
        console.log('[-] SSLContext hook failed: ' + e);
    }

    try {
        // Hook TrustManagerImpl
        var TrustManagerImpl = Java.use('com.android.org.conscrypt.TrustManagerImpl');
        TrustManagerImpl.verifyChain.implementation = function(untrustedChain, trustAnchorChain, host, clientAuth, ocspData, tlsSctData) {
            console.log('[+] TrustManagerImpl.verifyChain() called for: ' + host);
            console.log('[+] Bypassing certificate verification');
            return untrustedChain;
        };
        console.log('[+] Hooked TrustManagerImpl.verifyChain()');
    } catch(e) {
        console.log('[-] TrustManagerImpl hook failed: ' + e);
    }

    try {
        // Hook OkHttp CertificatePinner
        var CertificatePinner = Java.use('okhttp3.CertificatePinner');
        CertificatePinner.check.overload('java.lang.String', 'java.util.List').implementation = function(hostname, peerCertificates) {
            console.log('[+] OkHttp CertificatePinner.check() called for: ' + hostname);
            console.log('[+] Bypassing certificate pinning');
            return;
        };
        console.log('[+] Hooked OkHttp CertificatePinner.check()');
    } catch(e) {
        console.log('[-] OkHttp CertificatePinner hook failed: ' + e);
    }

    try {
        // Hook OkHttp3 CertificatePinner (newer version)
        var CertificatePinner3 = Java.use('okhttp3.CertificatePinner');
        CertificatePinner3.check$okhttp.overload('java.lang.String', 'kotlin.jvm.functions.Function0').implementation = function(hostname, func) {
            console.log('[+] OkHttp3 CertificatePinner.check() called for: ' + hostname);
            console.log('[+] Bypassing certificate pinning');
            return;
        };
        console.log('[+] Hooked OkHttp3 CertificatePinner.check()');
    } catch(e) {
        console.log('[-] OkHttp3 CertificatePinner hook failed: ' + e);
    }

    try {
        // Hook HostnameVerifier
        var HostnameVerifier = Java.use('javax.net.ssl.HostnameVerifier');
        var HttpsURLConnection = Java.use('javax.net.ssl.HttpsURLConnection');
        HttpsURLConnection.setDefaultHostnameVerifier.implementation = function(hostnameVerifier) {
            console.log('[+] HttpsURLConnection.setDefaultHostnameVerifier() called');
            console.log('[+] Installing permissive HostnameVerifier');

            var EmptyHostnameVerifier = Java.registerClass({
                name: 'com.sensepost.test.EmptyHostnameVerifier',
                implements: [HostnameVerifier],
                methods: {
                    verify: function(hostname, session) {
                        console.log('[+] HostnameVerifier.verify() called for: ' + hostname);
                        console.log('[+] Accepting hostname');
                        return true;
                    }
                }
            });

            this.setDefaultHostnameVerifier(EmptyHostnameVerifier.$new());
        };
        console.log('[+] Hooked HttpsURLConnection.setDefaultHostnameVerifier()');
    } catch(e) {
        console.log('[-] HostnameVerifier hook failed: ' + e);
    }

    try {
        // Hook NetworkSecurityPolicy
        var NetworkSecurityPolicy = Java.use('android.security.net.config.NetworkSecurityConfig');
        NetworkSecurityPolicy.isCleartextTrafficPermitted.overload().implementation = function() {
            console.log('[+] NetworkSecurityPolicy.isCleartextTrafficPermitted() called');
            return true;
        };
        NetworkSecurityPolicy.isCleartextTrafficPermitted.overload('java.lang.String').implementation = function(hostname) {
            console.log('[+] NetworkSecurityPolicy.isCleartextTrafficPermitted() called for: ' + hostname);
            return true;
        };
        console.log('[+] Hooked NetworkSecurityPolicy');
    } catch(e) {
        console.log('[-] NetworkSecurityPolicy hook failed: ' + e);
    }

    console.log('[*] SSL Pinning Bypass Complete!');
    console.log('[*] All HTTPS connections will now trust mitmproxy certificate');
});
