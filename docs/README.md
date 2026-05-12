# Prometheus Local Setup

## Project Structure

```
C:\projects\prometheus-local\
├── config\
│   └── prometheus.yml          # Main Prometheus configuration
├── data\
│   └── (tsdb storage)          # Time-series database files
├── scripts\
│   ├── install-service.bat     # Install Prometheus as Windows service via NSSM
│   ├── uninstall-service.bat   # Remove the Windows service
│   └── diagnose-and-fix.bat    # Diagnose NSSM crash and common issues
├── windows-service\
│   └── (service wrappers/logs) # NSSM wrapper logs
└── docs\
    ├── INSTALL.md              # Installation guide
    ├── TROUBLESHOOTING.md      # Troubleshooting the NSSM crash
    └── ACCESS.md               # How to access Prometheus
```

## Quick Start

1. **Download Prometheus**
   - Visit: https://prometheus.io/download/
   - Download the Windows binary (e.g., `prometheus-2.x.x.windows-amd64.zip`)
   - Extract `prometheus.exe` to `C:\projects\prometheus-local\`

2. **Download NSSM**
   - Visit: https://nssm.cc/download
   - Download `nssm-2.x.zip` and extract `nssm.exe` (x64 version)
   - Place `nssm.exe` in a folder in your PATH, or in `C:\projects\prometheus-local\scripts\`

3. **Install as Service**
   - Right-click `scripts\install-service.bat` → **Run as administrator**
   - This installs and starts `prometheus-service`

4. **Access Prometheus**
   - Open: http://localhost:9090
   - Status → Targets: http://localhost:9090/targets
   - Expression browser: http://localhost:9090/graph

## The NSSM Error You Are Seeing

> `[nssm] Service prometheus-service ran for less than 1500 milliseconds. Restart will be delayed by...`

This means the Prometheus process is **crashing immediately** after NSSM starts it.

### Common Causes

| Cause | Fix |
|-------|-----|
| `prometheus.exe` not found | Ensure `prometheus.exe` is in `C:\projects\prometheus-local\` |
| Invalid `prometheus.yml` | Run `scripts\diagnose-and-fix.bat` to validate |
| Data directory missing / locked | Create `data\` folder or fix permissions |
| Port 9090 already in use | Stop conflicting app or change port in config |
| Wrong path in NSSM parameters | Re-run `install-service.bat` to reset paths |
| Antivirus blocking | Add `prometheus.exe` to antivirus exclusions |

## Next Steps

- See `docs/INSTALL.md` for detailed installation instructions.
- See `docs/TROUBLESHOOTING.md` for deep-dive crash analysis.
- See `docs/ACCESS.md` for all access URLs and useful endpoints.
