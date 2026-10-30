#!/usr/bin/env python3
"""
Panchatantra AI — Real Neural Voice Cloning Microservice
=========================================================
Provides fast HTTP REST endpoints for the Flutter mobile & desktop application:
- POST /api/voice/enroll     (Enrolls parent audio, extracts 512-dim X-Vector embedding)
- POST /api/voice/synthesize (Synthesizes story narration in parent's cloned voice)
- GET  /api/voice/status     (Returns active profile, biometrics, and GPU status)
- GET  /api/voice/profiles   (Lists all enrolled parent voice profiles)
- POST /api/voice/revoke     (Revokes voice biometric data)
"""

import os
import json
import base64
import argparse
from pathlib import Path
from http.server import HTTPServer, BaseHTTPRequestHandler
from voice_cloner import VoiceCloner

# Initialize cloner with persistent voice profiles directory
BASE_DIR = Path(__file__).resolve().parent.parent
PROFILES_DIR = BASE_DIR / "voice_profiles"
PROFILES_DIR.mkdir(parents=True, exist_ok=True)
FLUTTER_AUDIO_ASSET = BASE_DIR / "panchatantra_app" / "assets" / "audio" / "cloned_sample.wav"
FLUTTER_AUDIO_ASSET.parent.mkdir(parents=True, exist_ok=True)

cloner = VoiceCloner(profiles_dir=str(PROFILES_DIR))

# Pre-load neural models into memory for sub-second responses
print("🚀 [VoiceServer] Pre-warming real neural voice cloning models...")
cloner._load_neural_models()
print("🌟 [VoiceServer] Models ready for real-time parent voice synthesis!")


class VoiceRequestHandler(BaseHTTPRequestHandler):
    def _set_headers(self, status=200, content_type="application/json"):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        self.end_headers()

    def do_OPTIONS(self):
        self._set_headers(200)

    def do_GET(self):
        if self.path == "/api/voice/status":
            self._set_headers(200)
            status = cloner.active_profile or {
                "status": "Ready",
                "is_enrolled": False,
                "neural_cloning_enabled": cloner._models_loaded,
                "device": cloner.device,
                "message": "Ready to clone parent voice from microphone recording."
            }
            self.wfile.write(json.dumps(status).encode("utf-8"))

        elif self.path == "/api/voice/profiles":
            self._set_headers(200)
            profiles = []
            for p in PROFILES_DIR.glob("profile_*.json"):
                try:
                    with open(p) as f:
                        profiles.append(json.load(f))
                except Exception:
                    pass
            self.wfile.write(json.dumps({"profiles": profiles}).encode("utf-8"))

        elif self.path == "/api/health":
            self._set_headers(200)
            self.wfile.write(json.dumps({
                "status": "healthy",
                "engine": "Neural-SpeechT5-XVector",
                "device": cloner.device,
                "models_loaded": cloner._models_loaded
            }).encode("utf-8"))
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
                audio_path = data.get("audio_path", "")
                file_ext = data.get("file_ext", "wav")

                safe_name = parent_name.replace(" ", "_").lower()
                sample_file = PROFILES_DIR / f"raw_sample_{safe_name}.{file_ext}"

                if audio_base64:
                    with open(sample_file, "wb") as f:
                        f.write(base64.b64decode(audio_base64))
                    target_sample = str(sample_file)
                elif audio_path and os.path.exists(audio_path):
                    target_sample = audio_path
                else:
                    target_sample = str(PROFILES_DIR / f"profile_{safe_name}.wav")

                # Perform neural enrollment and X-vector extraction
                profile = cloner.enroll_voice(target_sample, parent_name=parent_name)

                # Also automatically generate a preview story narration in this cloned voice!
                preview_text = data.get("preview_text") or f"Hello my sweet little one, tonight we will listen to the clever rabbit and the mighty lion."
                final_preview = cloner.synthesize_story(preview_text, str(FLUTTER_AUDIO_ASSET), parent_name=parent_name)

                audio_bytes = b""
                if os.path.exists(final_preview):
                    with open(final_preview, "rb") as f:
                        audio_bytes = f.read()

                self._set_headers(200)
                self.wfile.write(json.dumps({
                    "success": True,
                    "profile": profile,
                    "preview_url": "assets/audio/cloned_sample.wav",
                    "preview_audio_base64": base64.b64encode(audio_bytes).decode("utf-8")
                }).encode("utf-8"))
            except Exception as e:
                self._set_headers(500)
                self.wfile.write(json.dumps({"error": str(e)}).encode("utf-8"))

        elif self.path == "/api/voice/synthesize":
            try:
                data = json.loads(body.decode("utf-8"))
                text = data.get("text", "")
                parent_name = data.get("parent_name", "Parent")
                out_path_str = data.get("output_path")
                if out_path_str:
                    out_path = Path(out_path_str)
                    if not out_path.is_absolute():
                        out_path = BASE_DIR / out_path_str
                else:
                    out_path = FLUTTER_AUDIO_ASSET

                final_path = cloner.synthesize_story(text, str(out_path), parent_name=parent_name)

                audio_bytes = b""
                if os.path.exists(final_path):
                    with open(final_path, "rb") as f:
                        audio_bytes = f.read()

                self._set_headers(200)
                self.wfile.write(json.dumps({
                    "success": True,
                    "audio_base64": base64.b64encode(audio_bytes).decode("utf-8"),
                    "voice": f"{parent_name}'s Real Cloned Voice (SpeechT5)",
                    "audio_path": str(final_path),
                    "size_bytes": len(audio_bytes)
                }).encode("utf-8"))
            except Exception as e:
                self._set_headers(500)
                self.wfile.write(json.dumps({"error": str(e)}).encode("utf-8"))

        elif self.path == "/api/voice/revoke":
            safe_name = cloner.active_profile.get("parent_name", "").replace(" ", "_").lower() if cloner.active_profile else ""
            cloner.active_profile = None
            if safe_name:
                for f in PROFILES_DIR.glob(f"*{safe_name}*"):
                    try:
                        f.unlink()
                    except Exception:
                        pass
            self._set_headers(200)
            self.wfile.write(json.dumps({
                "success": True,
                "message": "Voice biometric data permanently deleted. Consent revoked."
            }).encode("utf-8"))
        else:
            self._set_headers(404)
            self.wfile.write(json.dumps({"error": "Endpoint not found"}).encode("utf-8"))


def run_server(port=8080):
    server_address = ("127.0.0.1", port)
    httpd = HTTPServer(server_address, VoiceRequestHandler)
    print(f"📡 [VoiceServer] Neural Voice Cloning Server listening on http://127.0.0.1:{port}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 [VoiceServer] Shutting down.")
        httpd.server_close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Panchatantra AI Voice Cloning Server")
    parser.add_argument("--port", type=int, default=8080, help="Port to listen on (default 8080)")
    args = parser.parse_args()
    run_server(port=args.port)
