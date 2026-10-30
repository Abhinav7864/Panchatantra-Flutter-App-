@echo off
chcp 65001 > nul
echo ===================================================================
echo  Panchatantra AI - Windows NVIDIA RTX 4070 Setup
echo  Installing High-Fidelity Coqui XTTS-v2 with CUDA 12.1 Acceleration
echo ===================================================================
echo.

:: Verify Python installation
python --version > nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not added to your system PATH!
    echo Please install Python 3.10 or 3.11 from https://www.python.org/downloads/
    echo (Make sure to check "Add python.exe to PATH" during installation)
    pause
    exit /b 1
)

:: Create Python virtual environment
if not exist "venv" (
    echo [*] Creating virtual environment (venv)...
    python -m venv venv
)

echo [*] Activating virtual environment...
call venv\Scripts\activate.bat

echo [*] Upgrading pip, setuptools, and wheel...
python -m pip install --upgrade pip setuptools wheel

echo.
echo [*] Installing PyTorch with CUDA 12.1 for RTX 40-Series (Ada Lovelace)...
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

echo.
echo [*] Installing Coqui XTTS-v2, soundfile, and dependencies...
if exist "requirements_windows_rtx.txt" (
    pip install -r requirements_windows_rtx.txt
) else if exist "panchatantra_app\requirements_windows_rtx.txt" (
    pip install -r panchatantra_app\requirements_windows_rtx.txt
)

echo.
echo ===================================================================
echo  Verifying NVIDIA CUDA & XTTS-v2 Installation...
echo ===================================================================
python -c "import torch; print('CUDA Available:', torch.cuda.is_available()); print('GPU Detected:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'None'); print('VRAM (GB):', round(torch.cuda.get_device_properties(0).total_memory / 1e9, 2) if torch.cuda.is_available() else 'N/A')"
python -c "from TTS.api import TTS; print('Coqui XTTS-v2 Library: Ready!')" 2> nul

echo.
echo ===================================================================
echo  Setup Complete! You can now start the server with:
echo  run_voice_server_windows.bat
echo ===================================================================
pause
