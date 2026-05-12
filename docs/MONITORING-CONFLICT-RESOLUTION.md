# Monitoring Conflict: iCUE + Prometheus (windows_exporter)

**Date**: 2026-05-12
**Issue**: System noise and log spam caused by conflicting `windows_exporter` services.

## Symptoms
- Two `windows_exporter` services were identified:
    1. `windows-exporter` (Running from `C:\projects\prometheus-local` on port 9182).
    2. `windows_exporter` (Crashing every 60s from `C:\Program Files\windows_exporter`).
- The second service was crashing repeatedly because port 9182 was already in use by the first service.
- Log spam in Windows Event Viewer and service instability.

## Root Cause
Adding an iCUE PSU USB cable introduced a new device on the USB/SMBus, which might have been related to the user's manual installation or a pre-existing installation of `windows_exporter` in `Program Files`. This created a port conflict with the project-specific exporter.

## Solution
1. **Identified the conflicting service**: `windows_exporter` pointing to `C:\Program Files\windows_exporter`.
2. **Stopped and deleted the service**: Used `sc.exe delete windows_exporter`.
3. **Removed the conflicting files**: Deleted the `C:\Program Files\windows_exporter` directory.
4. **Verified the primary service**: Ensured `windows-exporter` in `C:\projects\prometheus-local` is running correctly on port 9182.

## Verification
Run the following in PowerShell to ensure only one exporter is present:
```powershell
Get-Service -Name "windows*" | Select-Object Name, DisplayName, Status, PathName
```
Ensure `windows-exporter` is the only one running from the project directory.
