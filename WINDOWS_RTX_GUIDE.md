# Panchatantra AI — Windows RTX 4070 Setup Guide

This guide walks you through running Panchatantra with **Coqui XTTS-v2** high-fidelity zero-shot voice cloning on your **NVIDIA GeForce RTX 4070 (12GB VRAM)** Windows machine.

---

## Why XTTS-v2 on RTX 4070 Sounds Exactly Like You
- **Coqui XTTS-v2** is the leading open-source zero-shot voice cloner.
- Unlike SpeechT5 (which only applies basic pitch shifts), XTTS-v2 captures:
  - Exact human vocal timbre and vocal tract harmonics.
  - Authentic accent preservation (Indian English, British, American, etc.).
  - Natural pauses, breathing, and prosody from a 6-second audio clip.
  - Multilingual support for English and Hindi bedtime storytelling.
- Your **RTX 4070** synthesizes speech in **~200–400 ms** (15x real-time speed) using CUDA FP16 Tensor Cores.

---

## Step 1: Clone the Repository on Your Windows PC

Open **PowerShell** or **Command Prompt** and clone the project:
```cmd
git clone https://github.com/Abhinav7864/Panchatantra-Flutter-App-.git
cd Panchatantra-Flutter-App-
```

---

## Step 2: One-Click Environment Setup

We have prepared an automated setup script that installs PyTorch with CUDA 12.1 and XTTS-v2:

1. Double-click **`setup_windows_rtx.bat`**  
   *(or run `.\setup_windows_rtx.bat` in PowerShell/CMD)*.

### Manual Setup (Alternative)
If you prefer manual commands:
```cmd
python -m venv venv
venv\Scripts\activate.bat
python -m pip install --upgrade pip setuptools wheel
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
pip install -r requirements_windows_rtx.txt
```

---

## Step 3: Start the Neural Voice Engine

Double-click **`run_voice_server_windows.bat`**  
*(or run `python voice_clone_engine\voice_server.py --port 8080`)*.

You will see:
```text
🚀 [VoiceCloner] Loading Coqui XTTS-v2 model on NVIDIA GeForce RTX 4070 (CUDA FP16 Tensor Cores)...
✅ [VoiceCloner] Coqui XTTS-v2 active on NVIDIA GeForce RTX 4070!
🌟 [VoiceServer] Models ready for real-time parent voice synthesis!
```

---

## Step 4: Run the Panchatantra Flutter App on Windows

Open a second terminal window on your Windows PC:

```cmd
cd panchatantra_app
flutter pub get
flutter run -d windows
```
*(You can also run in Chrome using `flutter run -d chrome`)*.

---

## Step 5: Test Your Cloned Voice

1. In the app, navigate to **Step 2 (Parent Voice Studio)**.
2. Select your Windows microphone from the dropdown.
3. Tap **Record**, read the story sentence aloud for 6 to 10 seconds, and tap **Stop**.
4. Tap **Play** to listen back to your raw microphone sample.
5. Tap **"Clone My Voice Now ✨"** — your RTX 4070 will extract your vocal embedding in milliseconds.
6. Type any story sentence (e.g., *"Goodnight my little one, dream of brave lions and clever rabbits."*) and tap **"Synthesize My Voice ✨"**.
7. Listen to your speech generated in your actual voice and accent!
