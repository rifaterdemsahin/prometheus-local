# Verification Queries Reference

A record of all diagnostic queries and API calls used to verify Prometheus is collecting metrics on this machine.

**Machine**: Windows 11 Workstation  
**Prometheus PID**: 49304  
**Base URL**: `http://localhost:9090`  
**Date Verified**: 2026-05-12

---

## 1. Check If Prometheus Process Is Running

```powershell
Get-Process prometheus -ErrorAction SilentlyContinue | Select-Object Id, ProcessName, StartTime
```

**Expected Result**: Process object with `ProcessName = prometheus`  
**Actual Result**: ✅ PID 49304, running since 06:04:30

---

## 2. Read Current Configuration

```powershell
Get-Content "C:\projects\prometheus-local\config\prometheus.yml"
```

**Expected Result**: Valid YAML with `scrape_configs` section  
**Actual Result**: ✅ Config has `job_name: 'prometheus'` targeting `localhost:9090`

---

## 3. Check Data Directory Contents

```powershell
Get-ChildItem "C:\projects\prometheus-local\data" -Recurse -ErrorAction SilentlyContinue | Select-Object FullName, Length
```

**Expected Result**: `wal/`, `chunks_head/`, `lock` files exist  
**Actual Result**: ✅ WAL file `00000000` (104,214 bytes) active

---

## 4. Check Scrape Target Health (via API)

```powershell
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/targets" -UseBasicParsing | Select-Object -ExpandProperty Content
```

**What it does**: Lists all configured scrape targets and their health status.

**Expected Result**: JSON with `"health": "up"`  
**Actual Result**: ✅
```json
{
  "status": "success",
  "data": {
    "activeTargets": [
      {
        "labels": {"instance": "localhost:9090", "job": "prometheus"},
        "scrapeUrl": "http://localhost:9090/metrics",
        "health": "up",
        "scrapeInterval": "15s"
      }
    ]
  }
}
```

---

## 5. List All Available Metric Names

```powershell
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/label/__name__/values" -UseBasicParsing | Select-Object -ExpandProperty Content
```

**What it does**: Returns every metric name currently known to Prometheus.

**Expected Result**: JSON array with 100+ metric names  
**Actual Result**: ✅ **400+ metric names** including `up`, `go_goroutines`, `prometheus_tsdb_head_series`

---

## 6. Query the `up` Metric

```powershell
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query?query=up" -UseBasicParsing | Select-Object -ExpandProperty Content
```

**What it does**: Returns the health status of all scrape targets (`1` = up, `0` = down).

**Expected Result**: `value` = `1` for `instance="localhost:9090"`  
**Actual Result**: ✅
```json
{
  "status": "success",
  "data": {
    "resultType": "vector",
    "result": [
      {
        "metric": {
          "__name__": "up",
          "instance": "localhost:9090",
          "job": "prometheus"
        },
        "value": [1778562686.845, "1"]
      }
    ]
  }
}
```

---

## 7. Query Prometheus Build Info

```powershell
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query?query=prometheus_build_info" -UseBasicParsing | Select-Object -ExpandProperty Content
```

**What it does**: Returns version, Go version, branch, and revision.

**Expected Result**: Labels include `version` and `goversion`  
**Actual Result**: ✅ Prometheus 2.53.0, Go 1.22.4

---

## 8. Query Sample Ingestion Rate

```powershell
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query?query=rate(prometheus_tsdb_head_samples_appended_total[1m])" -UseBasicParsing | Select-Object -ExpandProperty Content
```

**What it does**: Calculates the rate of samples being written to TSDB per second.

**Expected Result**: Positive numeric value  
**Actual Result**: ✅ Positive rate confirmed

---

## Quick Reference Table

| # | Query / Command | Purpose | Expected Result |
|---|-----------------|---------|-----------------|
| 1 | `Get-Process prometheus` | Verify process running | Process object |
| 2 | `Get-Content config\prometheus.yml` | Verify config exists | YAML content |
| 3 | `Get-ChildItem data -Recurse` | Verify TSDB active | WAL files present |
| 4 | `api/v1/targets` | Check target health | `"health": "up"` |
| 5 | `api/v1/label/__name__/values` | List all metrics | Array of names |
| 6 | `api/v1/query?query=up` | Target up/down status | Value = `1` |
| 7 | `api/v1/query?query=prometheus_build_info` | Version info | Labels with version |
| 8 | `api/v1/query?query=rate(...)` | Ingestion rate | Positive number |

---

## How to Re-Run These Yourself

Open **PowerShell** and copy-paste any command above. All commands hit `http://localhost:9090` which is the Prometheus instance running on this machine.

If Prometheus is not running, start it first:
```powershell
cd C:\projects\prometheus-local
.\prometheus.exe --config.file=config\prometheus.yml --storage.tsdb.path=data --web.listen-address=:9090
```

For the web UI version of these queries, open http://localhost:9090/graph and type the PromQL query in the Expression box.
