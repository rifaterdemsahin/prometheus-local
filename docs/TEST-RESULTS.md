# Test Results: Metrics Collection

**Date**: 2026-05-12
**Machine**: Windows 11 Workstation
**Prometheus PID**: 49304
**Status**: ✅ PASSING

---

## Test 1: Process Running

```powershell
Get-Process prometheus
```

**Result**: ✅ Process found, PID 49304, running for ~7 minutes

---

## Test 2: Target Health API

```powershell
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/targets" -UseBasicParsing
```

**Result**: ✅
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

**Conclusion**: Target is UP and scraping every 15 seconds.

---

## Test 3: Metric Names Available

```powershell
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/label/__name__/values" -UseBasicParsing
```

**Result**: ✅ **400+ metric names** returned

Sample metrics found:
- `go_goroutines`
- `go_memstats_alloc_bytes`
- `prometheus_build_info`
- `prometheus_tsdb_head_series`
- `scrape_duration_seconds`
- `up`

---

## Test 4: Query Execution

```powershell
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query?query=up" -UseBasicParsing
```

**Result**: ✅
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

**Conclusion**: Query returns `up = 1`, confirming target is healthy.

---

## Test 5: Data Directory

```powershell
Get-ChildItem "C:\projects\prometheus-local\data" -Recurse
```

**Result**: ✅
```
C:\projects\prometheus-local\data\chunks_head
C:\projects\prometheus-local\data\wal
C:\projects\prometheus-local\data\lock
C:\projects\prometheus-local\data\queries.active
C:\projects\prometheus-local\data\wal\00000000  (104,214 bytes)
```

**Conclusion**: TSDB is active and writing WAL data.

---

## Test 6: Build Info

```powershell
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query?query=prometheus_build_info" -UseBasicParsing
```

**Result**: ✅
```json
{
  "metric": {
    "__name__": "prometheus_build_info",
    "branch": "HEAD",
    "goversion": "go1.22.4",
    "revision": "...",
    "version": "2.53.0"
  },
  "value": [..., "1"]
}
```

**Conclusion**: Prometheus 2.53.0 (Go 1.22.4) running correctly.

---

## Test 7: Sample Rate

```powershell
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query?query=rate(prometheus_tsdb_head_samples_appended_total[1m])" -UseBasicParsing
```

**Result**: ✅ Returns a positive value (samples are being appended)

---

## Summary

| Test | Status |
|------|--------|
| Process Running | ✅ PASS |
| Target Health | ✅ PASS |
| Metric Names Available | ✅ PASS (400+) |
| Query Execution | ✅ PASS |
| Data Directory Active | ✅ PASS |
| Build Info Correct | ✅ PASS |
| Sample Ingestion Rate | ✅ PASS |

**Overall Status**: ✅ ALL TESTS PASSING

Prometheus is successfully collecting and storing metrics on this machine.

---

## How to Reproduce These Tests

Open PowerShell and run any of the commands above. All tests query `http://localhost:9090` which is the Prometheus instance running on this machine.
