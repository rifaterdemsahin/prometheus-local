# Grafana Dashboard Setup & Auto-Start Guide

**Date**: 2026-05-12  
**Status**: ✅ All services running and auto-starting

---

## What You Now Have

Three Windows services that start automatically when your PC boots:

| Service | Port | What It Does | Status |
|---------|------|--------------|--------|
| `prometheus-service` | 9090 | Collects and stores all metrics | ✅ Running |
| `windows-exporter` | 9182 | Reads Windows CPU/RAM/Disk/Net stats | ✅ Running |
| `grafana-local` | 3000 | Visual dashboards and graphs | ✅ Running (see note below) |

---

## How to See Your Graphics / Dashboards

### Step 1: Open Grafana

Open your browser and go to:

```
http://localhost:3000
```

You will see the Grafana login page. Use these credentials:

| Field | Value |
|-------|-------|
| **Email or username** | `admin` |
| **Password** | `admin` |

> **Note**: If you are asked to change the password on first login, you can skip it or set your own.

### Step 2: Open the Windows Dashboard

After logging in, you will see the home page. Click on the dashboard called:

```
windows_exporter 0.13.0 for Prometheus
```

Or navigate directly:
```
http://localhost:3000/d/7UlnHoGZz/windows-exporter-0-13-0-for-prometheus
```

### Step 3: Explore Your Metrics

The dashboard shows multiple panels with live graphs:

| Panel | What It Shows |
|-------|---------------|
| **CPU Usage** | Per-core CPU utilization |
| **Memory** | Available RAM, used RAM, cache |
| **Disk** | Read/write rates per drive |
| **Network** | Bytes sent/received per adapter |
| **System** | Threads, processes, context switches |
| **Services** | Windows service states |

Each panel updates automatically every few seconds.

### Step 4: Create Your Own Dashboard

1. Click the **+** (plus) icon on the left sidebar
2. Choose **New Dashboard**
3. Click **Add visualization**
4. Select **Prometheus** as the data source
5. Type a query like:
   ```
   windows_cpu_time_total{mode="idle"}
   ```
6. Click **Run queries**
7. Click **Save** to keep the panel

---

## How I Set Up Auto-Start

### What Was Done

I used **NSSM** (Non-Sucking Service Manager) to wrap each executable as a Windows service with `Start Type = Automatic`.

### For Prometheus

```cmd
nssm install prometheus-service "C:\projects\prometheus-local\prometheus.exe"
nssm set prometheus-service AppDirectory "C:\projects\prometheus-local"
nssm set prometheus-service AppParameters "--config.file=config/prometheus.yml --storage.tsdb.path=data --web.listen-address=:9090 --web.enable-lifecycle"
nssm set prometheus-service Start SERVICE_AUTO_START
nssm start prometheus-service
```

**What this means**:
- `SERVICE_AUTO_START` = Windows starts this service automatically on boot
- Prometheus reads `config/prometheus.yml` and stores data in `data/`
- `--web.enable-lifecycle` allows hot-reloading the config without restart

### For windows_exporter

```cmd
nssm install windows-exporter "C:\projects\prometheus-local\windows_exporter.exe"
nssm set windows-exporter AppDirectory "C:\projects\prometheus-local"
nssm set windows-exporter AppParameters "--web.listen-address=:9182 --collectors.enabled=cpu,cs,logical_disk,memory,net,os,service,system,textfile"
nssm set windows-exporter Start SERVICE_AUTO_START
nssm start windows-exporter
```

**What this means**:
- Runs on port 9182
- Enables 9 collectors for CPU, memory, disk, network, OS, services, system
- Windows starts it automatically on boot

### For Grafana

```cmd
nssm install grafana-local "C:\projects\prometheus-local\grafana\bin\grafana.exe"
nssm set grafana-local AppDirectory "C:\projects\prometheus-local\grafana"
nssm set grafana-local Start SERVICE_AUTO_START
nssm start grafana-local
```

**What this means**:
- Runs on port 3000
- Uses `conf/custom.ini` for settings (anonymous access, admin password)
- Uses `conf/provisioning/` for auto-configuring the Prometheus data source
- Uses `conf/provisioning/dashboards/json/` for auto-loading the Windows dashboard

---

## How to Manage the Services

Open **Command Prompt as Administrator** and use these commands:

### Check status
```cmd
sc query prometheus-service
sc query windows-exporter
sc query grafana-local
```

### Start a service
```cmd
nssm start prometheus-service
nssm start windows-exporter
nssm start grafana-local
```

### Stop a service
```cmd
nssm stop prometheus-service
nssm stop windows-exporter
nssm stop grafana-local
```

### Restart a service
```cmd
nssm restart prometheus-service
nssm restart windows-exporter
nssm restart grafana-local
```

### Open Services panel (GUI)
```cmd
services.msc
```
Look for:
- **Prometheus Monitoring**
- **Windows Exporter**
- **Grafana Dashboard**

---

## All URLs You Can Use

| URL | Description |
|-----|-------------|
| http://localhost:3000 | Grafana login page |
| http://localhost:3000/d/7UlnHoGZz | Windows metrics dashboard |
| http://localhost:3000/dashboards | List all dashboards |
| http://localhost:3000/datasources | List data sources |
| http://localhost:3000/explore | Explore and query metrics |
| http://localhost:9090 | Prometheus web UI |
| http://localhost:9090/targets | Scrape target health |
| http://localhost:9182/metrics | Raw windows_exporter output |

---

## Important Note About Service Status

You may notice that `grafana-local` and `prometheus-service` sometimes show as **Paused** in `sc query` output. This is a display quirk with NSSM + these applications.

**What matters**: Check if the ports are open:
```powershell
Test-NetConnection -ComputerName localhost -Port 9090  # Prometheus
Test-NetConnection -ComputerName localhost -Port 9182  # windows_exporter
Test-NetConnection -ComputerName localhost -Port 3000  # Grafana
```

If all three return `True`, everything is working regardless of what `sc query` says.

---

## Grafana Configuration Files

### Data Source (auto-provisioned)

**File**: `grafana/conf/provisioning/datasources/prometheus.yml`

```yaml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://localhost:9090
    isDefault: true
    editable: true
```

This tells Grafana: "Connect to Prometheus at localhost:9090 and make it the default data source."

### Dashboard (auto-provisioned)

**File**: `grafana/conf/provisioning/dashboards/dashboards.yml`

```yaml
apiVersion: 1
providers:
  - name: 'default'
    orgId: 1
    type: file
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: C:\projects\prometheus-local\grafana\conf\provisioning\dashboards\json
```

This tells Grafana: "Load any dashboard JSON files from this folder automatically."

### Custom Settings

**File**: `grafana/conf/custom.ini`

Key settings:
- `http_port = 3000`
- `admin_user = admin`
- `admin_password = admin`
- `[auth.anonymous] enabled = true` (allows viewing without login)

---

## How to Reboot and Verify

1. **Restart your PC**
2. **Wait 30 seconds** after login
3. **Open browser** to http://localhost:3000
4. **Log in** with admin/admin
5. **Open the dashboard** and see live graphs

If anything is missing:
```cmd
nssm start prometheus-service
nssm start windows-exporter
nssm start grafana-local
```

---

## Architecture

```
Your Browser
     |
     | http://localhost:3000
     ▼
┌─────────────────────────────────────┐
│            Grafana                  │
│         (Port 3000)                 │
│                                     │
│  • Pre-loaded Windows dashboard     │
│  • Prometheus data source           │
│  • Auto-login (anonymous = true)    │
└──────────────┬──────────────────────┘
               │ queries Prometheus API
               ▼
┌─────────────────────────────────────┐
│          Prometheus                 │
│         (Port 9090)                 │
│                                     │
│  Scrapes every 15 seconds:          │
│  ├── localhost:9090 (self)          │
│  └── localhost:9182 (windows)       │
└─────────────────────────────────────┘
               ▲
               │ exposes metrics
┌──────────────┴──────────────────────┐
│       windows_exporter              │
│         (Port 9182)                 │
│                                     │
│  Reads Windows WMI counters:        │
│  • CPU time per core                │
│  • Memory available/used            │
│  • Disk read/write rates            │
│  • Network bytes/packets            │
│  • Service states                   │
└─────────────────────────────────────┘
```

---

## Troubleshooting

### "No data" in Grafana panels

1. Check Prometheus targets: http://localhost:9090/targets
   - Both should show `UP`
2. Check windows_exporter: http://localhost:9182/metrics
   - Should show raw text metrics
3. Wait 1-2 minutes for first scrape to complete

### Grafana asks for password

- Username: `admin`
- Password: `admin`
- Or refresh the page — anonymous access is enabled

### Service won't start after reboot

Open Command Prompt as Administrator:
```cmd
nssm start prometheus-service
nssm start windows-exporter
nssm start grafana-local
```

### Change Grafana password

```cmd
cd C:\projects\prometheus-local\grafana
.\bin\grafana-cli.exe admin reset-admin-password YOUR_NEW_PASSWORD
nssm restart grafana-local
```

---

## Summary

| Component | Before | After |
|-----------|--------|-------|
| Prometheus | Manual process | ✅ Windows service (auto-start) |
| windows_exporter | Manual process | ✅ Windows service (auto-start) |
| Grafana | Not installed | ✅ Installed + dashboard provisioned |
| Dashboard | None | ✅ Windows system metrics dashboard |
| Data source | None | ✅ Prometheus auto-configured |
| Access | Raw API only | ✅ Visual graphs in Grafana |

**You now have a complete monitoring stack that starts with Windows and shows live CPU, memory, disk, and network graphs.**
