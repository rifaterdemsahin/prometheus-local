# Troubleshooting the NSSM Crash

## The Error

```
[nssm] Service prometheus-service ran for less than 1500 milliseconds.
Restart will be delayed by 64000 milliseconds.
```

This means NSSM started `prometheus.exe`, but the process exited almost instantly.

## Immediate Diagnostic Steps

### 1. Run the Diagnostic Script

The fastest way to identify the issue:

1. Right-click `scripts\diagnose-and-fix.bat`
2. Select **Run as administrator**

This script checks:
- Existence of `prometheus.exe`
- Existence of `prometheus.yml`
- Data directory presence
- Port 9090 conflicts
- Manual launch test (reads crash output)
- Windows Event Log entries

### 2. Check NSSM Logs

Because `install-service.bat` configures stdout/stderr redirection, check:

```
C:\projects\prometheus-local\prometheus-service.out.log
C:\projects\prometheus-local\prometheus-service.err.log
```

If these files don't exist, NSSM may not have had time to create them, or the service parameters are wrong.

### 3. Check Windows Event Viewer

1. Press `Win + R`, type `eventvwr.msc`, press Enter.
2. Navigate to **Windows Logs → Application**.
3. Look for entries with Source = `nssm` or `prometheus-service`.

Common event log messages:

| Message | Meaning |
|---------|---------|
| `Service prometheus-service ran for less than 1500 ms` | Process crashed immediately |
| `The system cannot find the file specified` | `prometheus.exe` path is wrong |
| `Access is denied` | User account lacks permissions |

## Root Causes & Fixes

### Cause A: Missing or Misplaced `prometheus.exe`

**Symptom:** Event log says "The system cannot find the file specified."

**Fix:**
```cmd
REM Verify the file exists:
dir C:\projects\prometheus-local\prometheus.exe

REM If missing, download and extract it to that exact path.
```

### Cause B: Invalid `prometheus.yml`

**Symptom:** `err.log` contains YAML parse errors or "Error loading config."

**Fix:**
```cmd
REM Test config manually:
cd C:\projects\prometheus-local
prometheus.exe --config.file=config\prometheus.yml --storage.tsdb.path=data
```

Watch the console output. If it says:
```
Error loading config (--config.file=config\prometheus.yml)
```
...then your YAML is malformed. Use a YAML validator or restore the default config from `config\prometheus.yml`.

### Cause C: Data Directory Permissions

**Symptom:** `err.log` contains "permission denied" or "mkdir data: access is denied."

**Fix:**
1. Ensure the `data\` folder exists:
   ```cmd
   mkdir C:\projects\prometheus-local\data
   ```
2. Grant the service user (usually `Local System`) full control:
   ```cmd
   icacls C:\projects\prometheus-local\data /grant "NT AUTHORITY\SYSTEM:(OI)(CI)F"
   ```

### Cause D: Port 9090 Already in Use

**Symptom:** `err.log` contains "bind: address already in use" or "listen tcp :9090."

**Fix:**
1. Find the process using port 9090:
   ```cmd
   netstat -ano | findstr :9090
   ```
2. Either stop the conflicting process, or change Prometheus's port.
3. To change the port, edit `config\prometheus.yml` is **not** enough—you must also update the NSSM service parameters:
   ```cmd
   nssm set prometheus-service AppParameters "--config.file=\"C:\projects\prometheus-local\config\prometheus.yml\" --storage.tsdb.path=\"C:\projects\prometheus-local\data\" --web.listen-address=:9091"
   nssm restart prometheus-service
   ```

### Cause E: NSSM AppParameters Path Escaping

**Symptom:** Service was installed but logs show "unknown flag" or paths are split incorrectly.

**Fix:**
NSSM stores parameters as a single string. Incorrect escaping breaks the command.

Best practice: reinstall with the provided `install-service.bat`, which sets parameters correctly:
```
--config.file="C:\projects\prometheus-local\config\prometheus.yml" --storage.tsdb.path="C:\projects\prometheus-local\data" --web.listen-address=:9090
```

### Cause F: Antivirus / Windows Defender Blocking

**Symptom:** No logs at all; process exits instantly; Event Viewer shows nothing useful.

**Fix:**
Add exclusions for:
- `C:\projects\prometheus-local\prometheus.exe`
- `C:\projects\prometheus-local\data\`

## Manual Verification Checklist

Run these commands in an **administrator Command Prompt**:

```cmd
REM 1. Is the service installed?
sc query prometheus-service

REM 2. What are the NSSM parameters?
nssm dump prometheus-service

REM 3. Can prometheus start manually?
cd C:\projects\prometheus-local
prometheus.exe --config.file=config\prometheus.yml --storage.tsdb.path=data

REM 4. Is the config valid?
promtool.exe check config config\prometheus.yml
REM (promtool.exe comes with the Prometheus download)
```

## Still Crashing?

If the above doesn't resolve it:

1. Capture the exact output of `nssm dump prometheus-service`.
2. Copy the contents of `prometheus-service.err.log`.
3. Run `scripts\diagnose-and-fix.bat` and share the output.

With that information, the exact cause can be pinpointed.
