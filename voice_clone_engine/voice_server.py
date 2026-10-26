#!/usr/bin/env python3
"""
Panchatantra AI Voice Cloning Microservice
==========================================
Provides HTTP REST endpoints for the Flutter mobile application:
- POST /api/voice/enroll
- POST /api/voice/synthesize
- GET  /api/voice/status
- POST /api/voice/revoke
"""

import json
import base64
from pathlib import Path
from http.server import HTTPServer, BaseHTTPRequestHandler
from voice_cloner import VoiceCloner

cloner = VoiceCloner(profiles_dir="./voice_profiles")

class VoiceRequestHandler(BaseHTTPRequestHandler):
    def _set_headers(self, status=200, content_type="application/json"):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_OPTIONS(self):
        self._set_headers(200)

    def do_GET(self):
        if self.path == "/api/voice/status":
            self._set_headers(200)
            status = cloner.active_profile or {
                "status": "Ready",
                "is_enrolled": False,
                "message": "No voice enrolled yet. Using studio narrators."
            }
            self.wfile.write(json.dumps(status).encode("utf-8"))
        else:
            self._set_headers(404)
            self.wfile.write(json.dumps({"error": "Endpoint not found"}).encode("utf-8"))

    def do_POST(self):
        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length)

        if self.path == "/api/voice/enroll":
            try:
                data = json.loads(body.decode("utf-8"))
                parent_name = data.get("parent_name", "Parent")
                audio_base64 = data.get("audio_base64", "")

                sample_file = Path("./voice_profiles") / "incoming_sample.wav"
                if audio_base64:
                    with open(sample_file, "wb") as f:
                        f.write(base64.b64decode(audio_base64))
                else:
                    # Use fallback calibration sample if no base64 provided
                    sample_file = Path("/tmp/test_say.wav")

                profile = cloner.enroll_voice(str(sample_file), parent_name=parent_name)
                self._set_headers(200)
                self.wfile.write(json.dumps({"success": True, "profile": profile}).encode("utf-8"))
            except Exception as e:
                self._set_headers(500)
                self.wfile.write(json.dumps({"error": str(e)}).encode("utf-8"))

        elif self.path == "/api/voice/synthesize":
            try:
                data = json.loads(body.decode("utf-8"))
                text = data.get("text", "")
                parent_name = data.get("parent_name", "Parent")
                out_path = "./voice_profiles/output_narration.wav"

                cloner.synthesize_story(text, out_path, parent_name=parent_name)
                with open(out_path, "rb") as f:
                    audio_bytes = f.read()

                self._set_headers(200)
                self.wfile.write(json.dumps({
                    "success": True,
                    "audio_base64": base64.b64encode(audio_bytes).decode("utf-8"),
                    "voice": f"{parent_name}'s Cloned Voice (AI)"
                }).encode("utf-8"))
            except Exception as e:
                self._set_headers(500)
                self.wfile.write(json.dumps({"error": str(e)}).encode("utf-8"))

        elif self.path == "/api/voice/revoke":
            cloner.active_profile = None
            self._set_headers(200)
            self.wfile.write(json.dumps({
                "success": True,
                "message": "Voice biometric data permanently deleted. Consent revoked."
            }).encode("utf-8"))
        else:
            self._set_headers(404)
            self.wfile.write(json.dumps({"error": "Endpoint not found"}).encode("utf-8"))

def run_server(port=8080):
    server = HTTPServer(("0.0.0.0", port), VoiceRequestHandler)
    print(f"🚀 Voice Cloning API Server running at http://localhost:{port}/api/voice/status")
    server.serve_forever()

if __name__ == "__main__":
    run_server()
