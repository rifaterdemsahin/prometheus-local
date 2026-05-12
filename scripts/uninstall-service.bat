@echo off
setlocal

REM ============================================================
REM Prometheus NSSM Service Uninstaller
REM Run as Administrator
REM ============================================================

set SERVICE_NAME=prometheus-service

echo ==========================================
echo  Prometheus NSSM Service Uninstaller
echo ==========================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Please run as Administrator!
    pause
    exit /b 1
)

echo [INFO] Stopping service...
nssm stop %SERVICE_NAME% >nul 2>&1

timeout /t 2 >nul

echo [INFO] Removing service...
nssm remove %SERVICE_NAME% confirm >nul 2>&1

if %errorlevel% equ 0 (
    echo [SUCCESS] Service removed successfully.
) else (
    echo [INFO] Service may not exist or already removed.
)

pause
