@echo off
chcp 65001 > nul
set PYTHONUTF8=1
echo ===================================================================
echo  Panchatantra AI — High-Fidelity Neural Voice Server
echo  Hardware: NVIDIA GeForce RTX 4070 (CUDA FP16 Tensor Cores)
echo  Model: Coqui XTTS-v2 Zero-Shot Voice Cloner
echo ===================================================================
echo.

set PYTHON_EXE=
if exist "%USERPROFILE%\miniconda3\envs\panchatantra_xtts\python.exe" (
    set "PYTHON_EXE=%USERPROFILE%\miniconda3\envs\panchatantra_xtts\python.exe"
    echo [*] Using Coqui XTTS-v2 Python 3.10 environment (panchatantra_xtts)
) else if exist "venv\Scripts\python.exe" (
    set "PYTHON_EXE=venv\Scripts\python.exe"
    echo [*] Using venv environment
) else (
    set "PYTHON_EXE=python"
)

if exist "voice_clone_engine\voice_server.py" (
    "%PYTHON_EXE%" voice_clone_engine\voice_server.py --port 8080
) else if exist "panchatantra_app\voice_clone_engine\voice_server.py" (
    "%PYTHON_EXE%" panchatantra_app\voice_clone_engine\voice_server.py --port 8080
) else (
    echo [ERROR] voice_server.py not found!
)

pause
