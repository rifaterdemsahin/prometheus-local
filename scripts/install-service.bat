@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM Prometheus NSSM Service Installer
REM Run as Administrator
REM ============================================================

set PROMETHEUS_DIR=C:\projects\prometheus-local
set PROMETHEUS_EXE=%PROMETHEUS_DIR%\prometheus.exe
set SERVICE_NAME=prometheus-service
set DATA_DIR=%PROMETHEUS_DIR%\data
set CONFIG_FILE=%PROMETHEUS_DIR%\config\prometheus.yml

echo ==========================================
echo  Prometheus NSSM Service Installer
echo ==========================================

REM --- Check Admin Rights ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Please run this script as Administrator!
    pause
    exit /b 1
)

REM --- Check if prometheus.exe exists ---
if not exist "%PROMETHEUS_EXE%" (
    echo [ERROR] prometheus.exe not found at: %PROMETHEUS_EXE%
    echo Please download Prometheus and place prometheus.exe in: %PROMETHEUS_DIR%
    pause
    exit /b 1
)

REM --- Check if NSSM is available ---
where nssm >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] nssm.exe not found in PATH!
    echo Please download NSSM and add it to PATH, or place nssm.exe in this directory.
    echo Download: https://nssm.cc/download
    pause
    exit /b 1
)

REM --- Create data directory if missing ---
if not exist "%DATA_DIR%" (
    echo [INFO] Creating data directory: %DATA_DIR%
    mkdir "%DATA_DIR%"
)

REM --- Validate config file exists ---
if not exist "%CONFIG_FILE%" (
    echo [ERROR] Config file not found: %CONFIG_FILE%
    pause
    exit /b 1
)

REM --- Remove existing service if present ---
echo [INFO] Checking for existing service...
nssm stop %SERVICE_NAME% >nul 2>&1
nssm remove %SERVICE_NAME% confirm >nul 2>&1

REM --- Install service ---
echo [INFO] Installing service: %SERVICE_NAME%
nssm install %SERVICE_NAME% "%PROMETHEUS_EXE%"
nssm set %SERVICE_NAME% AppDirectory "%PROMETHEUS_DIR%"
nssm set %SERVICE_NAME% AppParameters "--config.file=\"%CONFIG_FILE%\" --storage.tsdb.path=\"%DATA_DIR%\" --web.listen-address=:9090"
nssm set %SERVICE_NAME% DisplayName "Prometheus Monitoring"
nssm set %SERVICE_NAME% Description "Prometheus local monitoring service"
nssm set %SERVICE_NAME% Start SERVICE_AUTO_START

REM --- Important: Set stdout/stderr logs so you can see crash reasons ---
nssm set %SERVICE_NAME% AppStdout "%PROMETHEUS_DIR%\prometheus-service.out.log"
nssm set %SERVICE_NAME% AppStderr "%PROMETHEUS_DIR%\prometheus-service.err.log"
nssm set %SERVICE_NAME% AppStdoutCreationDisposition 4
nssm set %SERVICE_NAME% AppStderrCreationDisposition 4
nssm set %SERVICE_NAME% AppRotateFiles 1
nssm set %SERVICE_NAME% AppRotateBytes 10485760

REM --- Start service ---
echo [INFO] Starting service...
nssm start %SERVICE_NAME%

timeout /t 3 >nul

REM --- Verify ---
sc query %SERVICE_NAME% | find "RUNNING" >nul
if %errorlevel% equ 0 (
    echo [SUCCESS] Service installed and running!
    echo [INFO] Access Prometheus at: http://localhost:9090
) else (
    echo [WARNING] Service may not have started properly.
    echo [INFO] Check logs:
    echo   - %PROMETHEUS_DIR%\prometheus-service.out.log
    echo   - %PROMETHEUS_DIR%\prometheus-service.err.log
)

pause
