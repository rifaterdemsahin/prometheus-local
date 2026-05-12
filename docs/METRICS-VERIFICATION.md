# Metrics Collection Verification

## Status: ✅ COLLECTING

Prometheus on this machine is actively collecting metrics.

| Check | Result |
|-------|--------|
| Process running | ✅ PID 49304 |
| Target health | ✅ `up` = 1 |
| Metrics available | ✅ 400+ metric names |
| Data directory | ✅ WAL files active |
| Last scrape | ✅ Within last 15 seconds |

---

## How Metrics Collection Works on This Machine

### 1. Configuration

File: `C:\projects\prometheus-local\config\prometheus.yml`

```yaml
global:
  scrape_interval: 15s          # Scrape every 15 seconds
  evaluation_interval: 15s      # Evaluate rules every 15 seconds

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']   # Scrape itself
    metrics_path: /metrics
```

### 2. What is being scraped

Currently, Prometheus is scraping **itself** at `http://localhost:9090/metrics`.

This means you can see:
- Prometheus build info (version, Go version)
- Go runtime metrics (goroutines, memory, GC)
- HTTP request metrics (requests, duration, response size)
- TSDB storage metrics (chunks, series, WAL)
- Scrape metrics (duration, samples scraped)

### 3. Where data is stored

- **Location**: `C:\projects\prometheus-local\data\`
- **Format**: Prometheus TSDB (Time Series Database)
- **Files**: WAL (Write-Ahead Log), chunks, indexes

---

## How to See Metrics in the UI

### Step 1: Open the Prometheus UI

Go to: http://localhost:9090/graph

### Step 2: Type a query in the Expression box

Click the **Expression** box and type:

```
up
```

### Step 3: Click Execute

Press the blue **Execute** button (or press `Shift + Enter`).

### Step 4: View results

You will see a table with:

| Metric | Value |
|--------|-------|
| `up{instance="localhost:9090",job="prometheus"}` | **1** |

Value `1` means the target is UP and healthy.

### Step 5: Try more queries

| Query | What it shows | Expected Value |
|-------|---------------|----------------|
| `up` | Target health | 1 |
| `prometheus_build_info` | Version info | Multiple labels |
| `go_goroutines` | Active goroutines | ~30-50 |
| `prometheus_tsdb_head_series` | Time series in memory | ~400+ |
| `rate(prometheus_tsdb_head_samples_appended_total[1m])` | Samples/sec | > 0 |
| `scrape_duration_seconds` | Last scrape time | ~0.005s |

### Step 6: View the Graph

1. Type: `go_goroutines`
2. Click **Execute**
3. Click the **Graph** tab (next to Table)
4. You will see a line chart of goroutine count over time

---

## API Verification (Command Line)

You can also verify metrics from PowerShell or Command Prompt:

### Check target health
```powershell
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/targets" -UseBasicParsing
```

### List all metric names
```powershell
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/label/__name__/values" -UseBasicParsing
```

### Query a specific metric
```powershell
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query?query=up" -UseBasicParsing
```

### Range query (last 5 minutes)
```powershell
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query_range?query=up&start=$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')&end=$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')&step=15s" -UseBasicParsing
```

---

## Common Misunderstanding

**"No data queried yet" does NOT mean "no metrics available."**

It simply means you haven't typed a query and clicked Execute yet. Prometheus has been collecting data since it started. You just need to ask for it.

Think of it like a database with data in it, but you haven't run a SELECT query yet.

---

## If You Still See No Data

1. **Check the target status**: http://localhost:9090/targets
   - Should show `prometheus` job with State = **UP**

2. **Check the query is valid**:
   - Type `up` (lowercase, no quotes needed)
   - Click **Execute**
   - Look at the **Table** tab

3. **Wait a moment**:
   - After starting Prometheus, it needs 1-2 scrape intervals (15-30 seconds) to collect the first data points

4. **Check the time range**:
   - If using Graph tab, make sure the time range includes "now"
   - The default range is usually 1 hour

---

## Metrics Available on This Machine

This Prometheus instance exposes the following metric categories:

| Category | Example Metrics | Count |
|----------|----------------|-------|
| Go Runtime | `go_goroutines`, `go_memstats_*` | ~60 |
| Process | `process_cpu_seconds_total`, `process_resident_memory_bytes` | ~7 |
| Prometheus API | `prometheus_api_*`, `prometheus_http_*` | ~15 |
| Prometheus Engine | `prometheus_engine_*` | ~10 |
| Prometheus Storage | `prometheus_tsdb_*` | ~80 |
| Prometheus Scrape | `scrape_duration_seconds`, `scrape_samples_scraped` | ~5 |
| Prometheus Targets | `prometheus_target_*` | ~40 |
| Prometheus Discovery | `prometheus_sd_*` | ~30 |
| Prometheus Rules | `prometheus_rule_*` | ~10 |
| Prometheus WAL | `prometheus_tsdb_wal_*` | ~15 |
| Connection Tracking | `net_conntrack_*` | ~7 |
| **Total** | | **~400+** |

---

## Next Steps

To collect metrics from other sources (not just Prometheus itself):

1. **Node Exporter** - Collect Windows host metrics (CPU, memory, disk)
2. **Application exporters** - Expose custom application metrics
3. **Pushgateway** - Push metrics from batch jobs

See `docs/INSTALL.md` for adding more scrape targets.
