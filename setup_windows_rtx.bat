@echo off
chcp 65001 > nul
set PYTHONUTF8=1
echo ===================================================================
echo  Panchatantra AI - Windows NVIDIA RTX 4070 Setup
echo  Installing High-Fidelity Voice Cloning with CUDA Acceleration
echo ===================================================================
echo.

REM Verify Python installation
python --version > nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not added to your system PATH!
    echo Please install Python from https://www.python.org/downloads/
    echo Note: Make sure to check "Add python.exe to PATH" during installation.
    pause
    exit /b 1
)

REM Create Python virtual environment if not present
if not exist "venv" (
    echo [*] Creating virtual environment venv...
    python -m venv venv
)

echo [*] Activating virtual environment...
call venv\Scripts\activate.bat
set PYTHONUTF8=1

echo [*] Upgrading pip, setuptools, and wheel...
python -m pip install --upgrade pip setuptools wheel

echo.
echo [*] Installing PyTorch with CUDA for RTX 40-Series (Ada Lovelace)...
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

echo.
echo [*] Installing audio and deep learning dependencies...
pip install soundfile scipy requests transformers accelerate

if exist "requirements_windows_rtx.txt" (
    pip install -r requirements_windows_rtx.txt
) else if exist "panchatantra_app\requirements_windows_rtx.txt" (
    pip install -r panchatantra_app\requirements_windows_rtx.txt
)

echo.
echo ===================================================================
echo  Verifying NVIDIA CUDA & Voice Engine Installation...
echo ===================================================================
python -c "import torch; print('CUDA Available:', torch.cuda.is_available()); print('GPU Detected:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'None'); print('VRAM (GB):', round(torch.cuda.get_device_properties(0).total_memory / 1e9, 2) if torch.cuda.is_available() else 'N/A')"
python -c "from TTS.api import TTS; print('Coqui XTTS-v2 Library: Ready!')" 2> nul
python -c "import transformers; print('Hugging Face Transformers: Ready!')" 2> nul

echo.
echo ===================================================================
echo  Setup Complete! You can now start the server with:
echo  run_voice_server_windows.bat
echo ===================================================================
pause
