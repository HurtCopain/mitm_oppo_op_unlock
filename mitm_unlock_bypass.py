#!/usr/bin/env python3
"""
MITM Proxy Script for Deep Testing Bootloader Unlock Bypass
Intercepts requests to lk-oneplus-cn.allawntech.com and injects fake approval response
"""

import json
from mitmproxy import http
from mitmproxy import ctx

class BootloaderUnlockBypass:
    def __init__(self):
        self.target_host = "lk-oneplus-cn.allawntech.com"
        self.endpoints = [
            "/api/v3/apply-unlock",
            "/api/v3/check-approve-result",
            "/api/v3/update-client-lock-status",
            "/api/v3/get-all-status"
        ]

    def request(self, flow: http.HTTPFlow) -> None:
        """Log intercepted requests"""
        if self.target_host in flow.request.pretty_host:
            ctx.log.info(f"[REQUEST] {flow.request.method} {flow.request.pretty_url}")
            ctx.log.info(f"[HEADERS] {dict(flow.request.headers)}")

            # Try to decode and log request body
            try:
                if flow.request.content:
                    body = flow.request.content.decode('utf-8')
                    ctx.log.info(f"[BODY] {body}")
            except Exception as e:
                ctx.log.warn(f"Could not decode request body: {e}")

    def response(self, flow: http.HTTPFlow) -> None:
        """Intercept and modify responses from OnePlus unlock server"""

        # Only intercept our target host
        if self.target_host not in flow.request.pretty_host:
            return

        # Check if this is one of our target endpoints
        request_path = flow.request.path
        is_target_endpoint = any(endpoint in request_path for endpoint in self.endpoints)

        if not is_target_endpoint:
            return

        ctx.log.info(f"[INTERCEPT] Modifying response for: {flow.request.pretty_url}")

        # Determine which endpoint and create appropriate fake response
        if "/apply-unlock" in request_path:
            fake_response = self.create_apply_unlock_response()
            ctx.log.alert("🔓 [BYPASS] Injecting FAKE APPROVAL for apply-unlock!")

        elif "/check-approve-result" in request_path:
            fake_response = self.create_check_approve_response()
            ctx.log.alert("✅ [BYPASS] Injecting APPROVED status for check-approve-result!")

        elif "/update-client-lock-status" in request_path:
            fake_response = self.create_update_status_response()
            ctx.log.alert("🔓 [BYPASS] Injecting SUCCESS for update-client-lock-status!")

        elif "/get-all-status" in request_path:
            fake_response = self.create_get_status_response()
            ctx.log.alert("📊 [BYPASS] Injecting UNLOCKED status for get-all-status!")

        else:
            # Default success response
            fake_response = self.create_default_success_response()
            ctx.log.warn("⚠️  [BYPASS] Using default success response")

        # Replace the response
        flow.response = http.Response.make(
            200,  # HTTP 200 OK
            json.dumps(fake_response, ensure_ascii=False).encode('utf-8'),
            {
                "Content-Type": "application/json; charset=utf-8",
                "X-Bypass": "MITM-Patched"
            }
        )

        ctx.log.info(f"[RESPONSE] Injected: {json.dumps(fake_response, indent=2)}")

    def create_apply_unlock_response(self):
        """Response for /apply-unlock endpoint"""
        return {
            "code": 200,
            "message": "Success (MITM Bypass)",
            "data": {
                "unlockCode": "MITM_BYPASS_UNLOCK_CODE_12345678",
                "applyStatus": 1,  # 1 = approved
                "clientStatus": 1,  # 1 = unlocked
                "exceptPassTime": "0"  # Immediate approval
            }
        }

    def create_check_approve_response(self):
        """Response for /check-approve-result endpoint"""
        return {
            "code": 200,
            "message": "Approved (MITM Bypass)",
            "data": {
                "unlockCode": "MITM_BYPASS_UNLOCK_CODE_12345678",
                "applyStatus": 1,  # 1 = approved
                "clientStatus": 1,  # 1 = unlocked
                "exceptPassTime": "0"
            }
        }

    def create_update_status_response(self):
        """Response for /update-client-lock-status endpoint"""
        return {
            "code": 200,
            "message": "Status updated (MITM Bypass)",
            "data": {
                "unlockCode": "MITM_BYPASS_UNLOCK_CODE_12345678",
                "applyStatus": 1,
                "clientStatus": 0,  # 0 means success for update
                "exceptPassTime": "0"
            }
        }

    def create_get_status_response(self):
        """Response for /get-all-status endpoint"""
        return {
            "code": 200,
            "message": "Status retrieved (MITM Bypass)",
            "data": {
                "unlockCode": "MITM_BYPASS_UNLOCK_CODE_12345678",
                "applyStatus": 1,
                "clientStatus": 1,
                "exceptPassTime": "0"
            }
        }

    def create_default_success_response(self):
        """Generic success response"""
        return {
            "code": 200,
            "message": "Success (MITM Bypass)",
            "data": {
                "unlockCode": "MITM_BYPASS_UNLOCK_CODE_12345678",
                "applyStatus": 1,
                "clientStatus": 1
            }
        }


# Create and register the addon
addons = [BootloaderUnlockBypass()]
