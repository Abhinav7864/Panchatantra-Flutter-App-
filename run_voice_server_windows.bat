@echo off
chcp 65001 > nul
echo ===================================================================
echo  Panchatantra AI — High-Fidelity Neural Voice Server
echo  Hardware: NVIDIA GeForce RTX 4070 (CUDA FP16 Tensor Cores)
echo  Model: Coqui XTTS-v2 Zero-Shot Voice Cloner
echo ===================================================================
echo.

if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
)

if exist "voice_clone_engine\voice_server.py" (
    python voice_clone_engine\voice_server.py --port 8080
) else if exist "panchatantra_app\voice_clone_engine\voice_server.py" (
    python panchatantra_app\voice_clone_engine\voice_server.py --port 8080
) else (
    echo [ERROR] voice_server.py not found!
)

pause
