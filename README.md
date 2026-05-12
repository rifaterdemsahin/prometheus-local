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

## Troubleshooting

If you see:
```
[nssm] Service prometheus-service ran for less than 1500 milliseconds.
```

Run `scripts\diagnose-and-fix.bat` as Administrator. See [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) for a full root-cause analysis.

## Project Structure

```
prometheus-local/
├── README.md                       # This file
├── config/
│   └── prometheus.yml              # Prometheus configuration
├── data/                           # TSDB storage (created at runtime)
├── docs/
│   ├── INSTALL.md                  # Step-by-step installation guide
│   ├── TROUBLESHOOTING.md          # NSSM crash investigation
│   └── ACCESS.md                   # URLs, APIs, and PromQL examples
├── scripts/
│   ├── install-service.bat         # Install & start NSSM service
│   ├── uninstall-service.bat       # Remove service
│   └── diagnose-and-fix.bat        # Automated crash diagnostics
└── windows-service/
    └── README.md                   # NSSM reference & commands
```

---

## Access

| URL | Description |
|-----|-------------|
| http://localhost:9090 | Prometheus Web UI |
| http://localhost:9090/targets | Scrape target health |
| http://localhost:9090/metrics | Self-metrics endpoint |

See [`docs/ACCESS.md`](docs/ACCESS.md) for the complete endpoint reference.
