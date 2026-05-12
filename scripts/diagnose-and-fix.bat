@echo off
setlocal

REM ============================================================
REM Diagnose and Fix Prometheus NSSM Crash
REM Run as Administrator
REM ============================================================

set PROMETHEUS_DIR=C:\projects\prometheus-local
set PROMETHEUS_EXE=%PROMETHEUS_DIR%\prometheus.exe
set SERVICE_NAME=prometheus-service
set DATA_DIR=%PROMETHEUS_DIR%\data
set CONFIG_FILE=%PROMETHEUS_DIR%\config\prometheus.yml

echo ==========================================
echo  Prometheus NSSM Crash Diagnostics
echo ==========================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Please run as Administrator!
    pause
    exit /b 1
)

echo.
echo [CHECK 1] Verifying prometheus.exe exists...
if exist "%PROMETHEUS_EXE%" (
    echo [PASS] Found: %PROMETHEUS_EXE%
) else (
    echo [FAIL] Missing: %PROMETHEUS_EXE%
    echo          Download from: https://prometheus.io/download/
    echo          Extract prometheus.exe to: %PROMETHEUS_DIR%
    pause
    exit /b 1
)

echo.
echo [CHECK 2] Verifying config file exists...
if exist "%CONFIG_FILE%" (
    echo [PASS] Found: %CONFIG_FILE%
) else (
    echo [FAIL] Missing: %CONFIG_FILE%
    echo          Creating default config...
    goto :create_config
)

echo.
echo [CHECK 3] Verifying data directory...
if exist "%DATA_DIR%" (
    echo [PASS] Found: %DATA_DIR%
) else (
    echo [WARN] Missing: %DATA_DIR%
    echo [FIX]  Creating directory...
    mkdir "%DATA_DIR%"
)

echo.
echo [CHECK 4] Checking if port 9090 is already in use...
netstat -ano | findstr ":9090" >nul
if %errorlevel% equ 0 (
    echo [WARN] Port 9090 is already in use!
    echo [INFO] You may need to stop the conflicting process or change the port.
    echo          Edit prometheus.yml or AppParameters to use a different port.
) else (
    echo [PASS] Port 9090 is free.
)

echo.
echo [CHECK 5] Testing Prometheus startup manually...
echo [INFO] Running prometheus.exe for 5 seconds to test...
start /B "" "%PROMETHEUS_EXE%" --config.file="%CONFIG_FILE%" --storage.tsdb.path="%DATA_DIR%" > "%PROMETHEUS_DIR%\test-run.log" 2>&1
timeout /t 5 >nul
taskkill /F /IM prometheus.exe >nul 2>&1

echo [INFO] Test log output (last 20 lines):
type "%PROMETHEUS_DIR%\test-run.log" 2>nul | findstr /V "^$" | tail -20 2>nul || type "%PROMETHEUS_DIR%\test-run.log"

echo.
echo [CHECK 6] Checking Windows Event Logs for NSSM errors...
echo [INFO] Recent Application log entries for nssm/prometheus:
powershell -Command "Get-EventLog -LogName Application -Source "nssm" -Newest 5 -ErrorAction SilentlyContinue | Format-Table TimeGenerated, EntryType, Message -Wrap"

echo.
echo ==========================================
echo  Diagnostics Complete
echo ==========================================
echo.
echo If the manual test above shows errors, fix the config or paths.
echo If it looks okay but the service still fails, check:
echo   1. The service AppParameters point to correct paths
echo   2. The service user has permissions on %PROMETHEUS_DIR%
echo   3. Antivirus is not blocking prometheus.exe
echo.
pause
exit /b 0

:create_config
echo global: > "%CONFIG_FILE%"
echo   scrape_interval: 15s >> "%CONFIG_FILE%"
echo scrape_configs: >> "%CONFIG_FILE%"
echo   - job_name: 'prometheus' >> "%CONFIG_FILE%"
echo     static_configs: >> "%CONFIG_FILE%"
echo       - targets: ['localhost:9090'] >> "%CONFIG_FILE%"
echo [DONE] Created default config at %CONFIG_FILE%
goto :eof
