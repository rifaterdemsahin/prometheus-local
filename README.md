# prometheus-local

A local Prometheus monitoring stack running as a Windows service via NSSM (Non-Sucking Service Manager), with complete installation scripts, diagnostics, and documentation.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         Windows OS                          │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           Service Control Manager (SCM)             │   │
│  │                                                     │   │
│  │   Service Name: prometheus-service                  │   │
│  │   Display Name: Prometheus Monitoring               │   │
│  │   Start Type:   Automatic                           │   │
│  └──────────────────────┬──────────────────────────────┘   │
│                         │                                   │
│                         ▼                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         NSSM (Non-Sucking Service Manager)          │   │
│  │                                                     │   │
│  │  • Wraps prometheus.exe as a Windows service        │   │
│  │  • Handles crash restarts with backoff              │   │
│  │  • Captures stdout/stderr to log files              │   │
│  └──────────────────────┬──────────────────────────────┘   │
│                         │                                   │
│                         ▼                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Prometheus Process                     │   │
│  │              (prometheus.exe)                       │   │
│  │                                                     │   │
│  │  Arguments:                                         │   │
│  │   --config.file=C:\projects\prometheus-local\       │   │
│  │     config\prometheus.yml                           │   │
│  │   --storage.tsdb.path=C:\projects\prometheus-local\ │   │
│  │     data                                            │   │
│  │   --web.listen-address=:9090                        │   │
│  └──────────────────────┬──────────────────────────────┘   │
│                         │                                   │
│           ┌─────────────┴─────────────┐                     │
│           ▼                           ▼                     │
│  ┌──────────────┐            ┌──────────────────┐          │
│  │   Config     │            │   TSDB Storage   │          │
│  │  prometheus  │            │    data\         │          │
│  │     .yml     │            │                  │          │
│  └──────────────┘            └──────────────────┘          │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              HTTP Web Interface                     │   │
│  │                  :9090                              │   │
│  │                                                     │   │
│  │   Endpoints:                                        │   │
│  │   • /          → Web UI (expression browser)        │   │
│  │   • /metrics   → Prometheus self-metrics            │   │
│  │   • /api/v1/*  → Query & management APIs            │   │
│  │   • /targets   → Scrape target health               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Component Breakdown

| Component | Purpose | Location |
|-----------|---------|----------|
| **prometheus.exe** | Core TSDB and scraping engine | `C:\projects\prometheus-local\prometheus.exe` |
| **prometheus.yml** | Scrape configs, rules, alerting | `config\prometheus.yml` |
| **data\** | On-disk time-series database | `data\` |
| **NSSM** | Windows service wrapper | `nssm.exe` (in PATH) |
| **install-service.bat** | One-click service installer | `scripts\install-service.bat` |
| **diagnose-and-fix.bat** | Crash diagnostics & repair | `scripts\diagnose-and-fix.bat` |
| **uninstall-service.bat** | Clean service removal | `scripts\uninstall-service.bat` |
| **Log files** | stdout/stderr from the service | `prometheus-service.out.log`, `.err.log` |

### Data Flow

1. **NSSM** starts `prometheus.exe` when Windows boots (or manually via Services panel).
2. **Prometheus** reads `config\prometheus.yml` to know what targets to scrape.
3. The built-in **TSDB** writes scraped metrics to the `data\` directory.
4. The **Web UI** (port 9090) serves the expression browser and REST APIs.
5. If Prometheus crashes, **NSSM** logs the reason and restarts it automatically.

---

## Quick Start

1. Download `prometheus.exe` → place in this folder.
2. Download `nssm.exe` (x64) → add to PATH.
3. Run `scripts\install-service.bat` as **Administrator**.
4. Open http://localhost:9090

For detailed instructions, see [`docs/INSTALL.md`](docs/INSTALL.md).

---

## Running on Your Local Machine

You have two ways to run Prometheus locally: as a one-off test or as a persistent Windows service.

### Option A: Run Manually (for testing)

Open a **Command Prompt** or **PowerShell** and run:

```cmd
cd C:\projects\prometheus-local
prometheus.exe --config.file=config\prometheus.yml --storage.tsdb.path=data --web.listen-address=:9090
```

You will see log output in the console. Leave the window open. To stop, press `Ctrl + C`.

Then open your browser to http://localhost:9090.

> **Tip:** Use this method when you are debugging or verifying your configuration before installing the service.

### Option B: Run as a Windows Service (for production / always-on)

Run `scripts\install-service.bat` as **Administrator**.

This installs `prometheus-service` so Prometheus starts automatically with Windows and restarts if it crashes.

To check the service status:
```cmd
sc query prometheus-service
```

To start or stop:
```cmd
nssm start prometheus-service
nssm stop prometheus-service
nssm restart prometheus-service
```

---

## Troubleshooting

If you see:
```
[nssm] Service prometheus-service ran for less than 1500 milliseconds.
```

### How to Run `diagnose-and-fix.bat`

1. Open **File Explorer** and go to `C:\projects\prometheus-local\scripts\`.
2. Right-click on `diagnose-and-fix.bat`.
3. Select **Run as administrator**.
4. The script will automatically check:
   - If `prometheus.exe` exists
   - If `prometheus.yml` is present
   - If the `data\` directory exists (creates it if missing)
   - If port 9090 is already in use
   - Whether Prometheus can start manually
   - Recent Windows Event Log entries for NSSM

5. Follow any `[FIX]` instructions the script prints.

### Still Crashing?

Check the log files created by NSSM:
- `C:\projects\prometheus-local\prometheus-service.out.log`
- `C:\projects\prometheus-local\prometheus-service.err.log`

Or read [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) for a full root-cause analysis.

## Project Structure

```
prometheus-local/
├── README.md                           # This file
├── config/
│   └── prometheus.yml                  # Prometheus configuration
├── data/                               # TSDB storage (created at runtime)
├── docs/
│   ├── INSTALL.md                      # Step-by-step installation guide
│   ├── TROUBLESHOOTING.md              # NSSM crash investigation
│   ├── ACCESS.md                       # URLs, APIs, and PromQL examples
│   ├── METRICS-VERIFICATION.md         # How metrics collection works + how to query
│   ├── TEST-RESULTS.md                 # Verified test results on this machine
│   ├── VERIFICATION-QUERIES.md         # All diagnostic queries used
│   └── TEST-LINKS.md                   # 400+ ready-to-use URLs and API links
├── scripts/
│   ├── install-service.bat             # Install & start NSSM service
│   ├── uninstall-service.bat           # Remove service
│   └── diagnose-and-fix.bat            # Automated crash diagnostics
└── windows-service/
    └── README.md                       # NSSM reference & commands
```

---

## Access

| URL | Description |
|-----|-------------|
| http://localhost:9090 | Prometheus Web UI |
| http://localhost:9090/targets | Scrape target health |
| http://localhost:9090/metrics | Self-metrics endpoint |

See [`docs/ACCESS.md`](docs/ACCESS.md) for the complete endpoint reference.

---

## Getting Metrics on Your Workstation

Once Prometheus is running (manually or as a service), open your browser and go to:

```
http://localhost:9090/graph
```

You will see the Prometheus expression browser:

![Prometheus UI](docs/images/prometheus-ui.png)

> **Important**: Seeing **"No data queried yet"** is normal! It means Prometheus is running and ready — you just haven't typed a query yet. Metrics are being collected in the background every 15 seconds.

### How to query metrics (step by step)

**Step 1 — Type a query**

Click the **Expression** box at the top and type. As you type, Prometheus shows an **autocomplete dropdown** with all available metrics:

![Prometheus Autocomplete](docs/images/prometheus-autocomplete.png)

```
up
```

**Step 2 — Click Execute**

Press the blue **Execute** button (or press `Shift + Enter`).

**Step 3 — View results**

You will see a table showing:

| Metric | Value |
|--------|-------|
| `up{instance="localhost:9090",job="prometheus"}` | **1** |

Value **1** = target is UP and healthy. ✅

**Step 4 — Try the Graph tab**

Type `go_goroutines` → click **Execute** → click the **Graph** tab. You will see a line chart.

### Common starter queries

| Query | What it shows |
|-------|---------------|
| `up` | Health of all targets (`1` = up) |
| `prometheus_build_info` | Version and build details |
| `go_goroutines` | Active goroutines |
| `prometheus_tsdb_head_series` | Time series in memory |
| `rate(prometheus_tsdb_head_samples_appended_total[1m])` | Samples ingested per second |
| `scrape_duration_seconds` | Time taken per scrape |

### Quick API test (PowerShell)

```powershell
# Check if target is up
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query?query=up" -UseBasicParsing

# List all 400+ metric names
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/label/__name__/values" -UseBasicParsing
```

For the full API reference, see [`docs/ACCESS.md`](docs/ACCESS.md).
For verified test results on this machine, see [`docs/TEST-RESULTS.md`](docs/TEST-RESULTS.md).
For a deep dive into how metrics collection works, see [`docs/METRICS-VERIFICATION.md`](docs/METRICS-VERIFICATION.md).
For **400+ ready-to-test URLs and direct links**, see [`docs/TEST-LINKS.md`](docs/TEST-LINKS.md) — copy-paste any URL into your browser.
