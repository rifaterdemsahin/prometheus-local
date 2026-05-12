# Installation Guide

## Prerequisites

- Windows 10/11 or Windows Server 2016+
- Administrator privileges
- ~200 MB disk space

## Step 1: Download Prometheus

1. Go to https://prometheus.io/download/
2. Find the latest Windows release, e.g.:
   ```
   prometheus-2.53.0.windows-amd64.zip
   ```
3. Extract the ZIP.
4. Copy **only** `prometheus.exe` into:
   ```
   C:\projects\prometheus-local\
   ```

> You do **not** need the other files (`promtool.exe`, `prometheus.yml` from the ZIP) because this project already provides a curated config.

## Step 2: Download NSSM (Non-Sucking Service Manager)

1. Go to https://nssm.cc/download
2. Download the latest ZIP.
3. Extract the correct architecture:
   - 64-bit Windows: `nssm-2.x\win64\nssm.exe`
   - 32-bit Windows: `nssm-2.x\win32\nssm.exe`
4. Place `nssm.exe` in one of these locations:
   - A directory already in your system `PATH` (recommended)
   - `C:\projects\prometheus-local\scripts\`

To verify NSSM is available, open a Command Prompt and run:
```cmd
nssm version
```

## Step 3: Verify Project Structure

Ensure your `C:\projects\prometheus-local\` looks like this:

```
prometheus-local\
├── prometheus.exe              <-- downloaded binary
├── config\
│   └── prometheus.yml          <-- provided by this project
├── data\
│   (empty, will be auto-created)
└── scripts\
    ├── install-service.bat
    ├── uninstall-service.bat
    └── diagnose-and-fix.bat
```

## Step 4: Install the Windows Service

1. Open File Explorer to `C:\projects\prometheus-local\scripts\`
2. Right-click `install-service.bat`
3. Select **Run as administrator**
4. The script will:
   - Validate `prometheus.exe` and `nssm.exe`
   - Create the `data\` directory if missing
   - Install `prometheus-service` via NSSM
   - Configure stdout/stderr logging
   - Start the service

### Successful Output
```
[INFO] Installing service: prometheus-service
[INFO] Starting service...
[SUCCESS] Service installed and running!
[INFO] Access Prometheus at: http://localhost:9090
```

## Step 5: Confirm Service is Running

Open PowerShell or CMD and run:
```powershell
sc query prometheus-service
```

Look for `STATE: 4 RUNNING`.

Alternatively, open **Services** (`services.msc`) and look for **Prometheus Monitoring**.

## Step 6: Access the UI

Open your browser to:
```
http://localhost:9090
```

See `ACCESS.md` for all available URLs.

## Uninstalling

To remove the service:
1. Right-click `scripts\uninstall-service.bat`
2. Select **Run as administrator**

This stops and deletes the service but **preserves** your data in `data\`.

## Upgrading Prometheus

1. Stop the service:
   ```cmd
   nssm stop prometheus-service
   ```
2. Replace `prometheus.exe` with the new version.
3. Start the service:
   ```cmd
   nssm start prometheus-service
   ```
