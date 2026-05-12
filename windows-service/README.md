# NSSM Service Wrapper Notes

## Why NSSM?

Prometheus does not ship with a native Windows service binary. NSSM wraps any executable as a Windows service, handling:
- Service registration with the Service Control Manager (SCM)
- Auto-restart on crash
- Stdout/stderr logging
- Graceful shutdown on service stop

## Files in This Directory

This directory is reserved for NSSM-related runtime files:
- Service wrapper logs (if redirected here)
- Backup dumps of service configuration

## Service Configuration Summary

When you run `scripts\install-service.bat`, the following NSSM parameters are set:

| NSSM Parameter | Value |
|----------------|-------|
| `Application` | `C:\projects\prometheus-local\prometheus.exe` |
| `AppDirectory` | `C:\projects\prometheus-local` |
| `AppParameters` | `--config.file="C:\projects\prometheus-local\config\prometheus.yml" --storage.tsdb.path="C:\projects\prometheus-local\data" --web.listen-address=:9090` |
| `DisplayName` | `Prometheus Monitoring` |
| `Start` | `SERVICE_AUTO_START` |
| `AppStdout` | `C:\projects\prometheus-local\prometheus-service.out.log` |
| `AppStderr` | `C:\projects\prometheus-local\prometheus-service.err.log` |

## Useful NSSM Commands

Open an **administrator Command Prompt** to run these:

```cmd
REM Check service status
nssm status prometheus-service

REM Start service
nssm start prometheus-service

REM Stop service
nssm stop prometheus-service

REM Restart service
nssm restart prometheus-service

REM View/edit parameters in GUI
nssm edit prometheus-service

REM Dump all parameters to console
nssm dump prometheus-service

REM Rotate logs manually
nssm rotate prometheus-service
```

## NSSM Download

- Website: https://nssm.cc/
- Download: https://nssm.cc/download
- Current stable version: 2.24

Ensure you use the matching architecture (`win64` for 64-bit Windows).
