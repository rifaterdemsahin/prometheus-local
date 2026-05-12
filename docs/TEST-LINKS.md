# Prometheus Test Links & URLs Reference

All URLs you can use to test and explore your local Prometheus instance.

**Base URL**: `http://localhost:9090`  
**Machine**: Windows 11 Workstation  
**Status**: ✅ Running and collecting metrics

---

## Web UI Pages

| URL | Description | What You'll See |
|-----|-------------|-----------------|
| http://localhost:9090 | **Home / Expression Browser** | Main query interface with autocomplete |
| http://localhost:9090/graph | **Graph page** | Same as home, focused on graphing |
| http://localhost:9090/alerts | **Alerts** | Currently configured alerts (empty by default) |
| http://localhost:9090/targets | **Targets** | Scrape target health and status |
| http://localhost:9090/service-discovery | **Service Discovery** | Discovered targets and labels |
| http://localhost:9090/status | **Runtime & Build Info** | Version, flags, uptime, config |
| http://localhost:9090/flags | **Command-Line Flags** | All startup flags and values |
| http://localhost:9090/config | **Configuration** | Currently loaded YAML config |
| http://localhost:9090/rules | **Rules** | Recording and alerting rules |
| http://localhost:9090/tsdb-status | **TSDB Status** | Head stats, cardinality, label stats |
| http://localhost:9090/histogram | **Native Histograms** | Native histogram debugging page |

---

## Metrics Endpoints (Raw Data)

| URL | Description | Format |
|-----|-------------|--------|
| http://localhost:9090/metrics | **Prometheus self-metrics** | OpenMetrics / Prometheus text |
| http://localhost:9090/api/v1/query | **Instant Query API** | JSON |
| http://localhost:9090/api/v1/query_range | **Range Query API** | JSON |
| http://localhost:9090/api/v1/series | **Series Metadata API** | JSON |
| http://localhost:9090/api/v1/labels | **Label Names API** | JSON |
| http://localhost:9090/api/v1/label/__name__/values | **Metric Names List** | JSON |
| http://localhost:9090/api/v1/targets | **Targets API** | JSON |
| http://localhost:9090/api/v1/targets/metadata | **Target Metadata API** | JSON |
| http://localhost:9090/api/v1/status/buildinfo | **Build Info API** | JSON |
| http://localhost:9090/api/v1/status/runtimeinfo | **Runtime Info API** | JSON |
| http://localhost:9090/api/v1/status/tsdb | **TSDB Stats API** | JSON |
| http://localhost:9090/api/v1/status/walreplay | **WAL Replay Status** | JSON |
| http://localhost:9090/api/v1/status/flags | **Flags API** | JSON |
| http://localhost:9090/api/v1/status/config | **Config API** | JSON |

---

## Ready-to-Use Query URLs

Copy and paste these directly into your browser:

### Basic Health Checks

```
http://localhost:9090/api/v1/query?query=up
```
Returns: Target health (`1` = up, `0` = down)

```
http://localhost:9090/api/v1/query?query=prometheus_build_info
```
Returns: Version, Go version, revision

```
http://localhost:9090/api/v1/query?query=prometheus_ready
```
Returns: Readiness status

### Go Runtime Metrics

```
http://localhost:9090/api/v1/query?query=go_goroutines
```
Returns: Number of active goroutines

```
http://localhost:9090/api/v1/query?query=go_memstats_alloc_bytes
```
Returns: Current memory allocation in bytes

```
http://localhost:9090/api/v1/query?query=go_memstats_heap_alloc_bytes
```
Returns: Heap allocation in bytes

```
http://localhost:9090/api/v1/query?query=go_threads
```
Returns: Number of OS threads

### Process Metrics

```
http://localhost:9090/api/v1/query?query=process_cpu_seconds_total
```
Returns: Total CPU seconds consumed

```
http://localhost:9090/api/v1/query?query=process_resident_memory_bytes
```
Returns: Resident memory (RAM) usage

```
http://localhost:9090/api/v1/query?query=process_open_fds
```
Returns: Number of open file descriptors

```
http://localhost:9090/api/v1/query?query=process_virtual_memory_bytes
```
Returns: Virtual memory size

### Prometheus Engine Metrics

```
http://localhost:9090/api/v1/query?query=prometheus_engine_queries
```
Returns: Currently active queries

```
http://localhost:9090/api/v1/query?query=prometheus_engine_queries_concurrent_max
```
Returns: Max concurrent queries allowed

```
http://localhost:9090/api/v1/query?query=prometheus_engine_query_log_enabled
```
Returns: Whether query logging is enabled

### TSDB (Storage) Metrics

```
http://localhost:9090/api/v1/query?query=prometheus_tsdb_head_series
```
Returns: Number of time series in memory

```
http://localhost:9090/api/v1/query?query=prometheus_tsdb_head_chunks
```
Returns: Number of chunks in memory

```
http://localhost:9090/api/v1/query?query=prometheus_tsdb_storage_blocks_bytes
```
Returns: Total disk usage of TSDB blocks

```
http://localhost:9090/api/v1/query?query=prometheus_tsdb_head_samples_appended_total
```
Returns: Total samples appended (counter)

```
http://localhost:9090/api/v1/query?query=rate(prometheus_tsdb_head_samples_appended_total[1m])
```
Returns: Samples per second ingestion rate

```
http://localhost:9090/api/v1/query?query=prometheus_tsdb_wal_storage_size_bytes
```
Returns: WAL storage size in bytes

```
http://localhost:9090/api/v1/query?query=prometheus_tsdb_blocks_loaded
```
Returns: Number of loaded blocks

### Scrape Metrics

```
http://localhost:9090/api/v1/query?query=scrape_duration_seconds
```
Returns: Duration of last scrape

```
http://localhost:9090/api/v1/query?query=scrape_samples_scraped
```
Returns: Samples scraped in last scrape

```
http://localhost:9090/api/v1/query?query=scrape_samples_post_metric_relabeling
```
Returns: Samples after relabeling

```
http://localhost:9090/api/v1/query?query=scrape_series_added
```
Returns: New series added in last scrape

### HTTP/API Metrics

```
http://localhost:9090/api/v1/query?query=prometheus_http_requests_total
```
Returns: Total HTTP requests by handler, code, method

```
http://localhost:9090/api/v1/query?query=rate(prometheus_http_requests_total[5m])
```
Returns: HTTP request rate per second (5m avg)

```
http://localhost:9090/api/v1/query?query=prometheus_http_request_duration_seconds_bucket
```
Returns: Request duration histogram buckets

```
http://localhost:9090/api/v1/query?query=prometheus_http_response_size_bytes
```
Returns: Response size statistics

### Service Discovery Metrics

```
http://localhost:9090/api/v1/query?query=prometheus_sd_discovered_targets
```
Returns: Number of discovered targets

```
http://localhost:9090/api/v1/query?query=prometheus_sd_updates_total
```
Returns: Total SD updates processed

```
http://localhost:9090/api/v1/query?query=prometheus_sd_received_updates_total
```
Returns: Total SD updates received

### Notification Metrics

```
http://localhost:9090/api/v1/query?query=prometheus_notifications_dropped_total
```
Returns: Total dropped notifications

```
http://localhost:9090/api/v1/query?query=prometheus_notifications_queue_length
```
Returns: Current notification queue length

---

## Range Query URLs (With Time Windows)

These show data over a time range (good for graphs):

### Last 1 hour
```
http://localhost:9090/api/v1/query_range?query=up&start=2026-05-12T05:00:00Z&end=2026-05-12T06:00:00Z&step=15s
```

### Last 5 minutes of ingestion rate
```
http://localhost:9090/api/v1/query_range?query=rate(prometheus_tsdb_head_samples_appended_total[1m])&start=2026-05-12T05:55:00Z&end=2026-05-12T06:00:00Z&step=15s
```

### Go goroutines over time
```
http://localhost:9090/api/v1/query_range?query=go_goroutines&start=2026-05-12T05:00:00Z&end=2026-05-12T06:00:00Z&step=15s
```

### Memory usage over time
```
http://localhost:9090/api/v1/query_range?query=process_resident_memory_bytes&start=2026-05-12T05:00:00Z&end=2026-05-12T06:00:00Z&step=15s
```

---

## Web UI Query Examples (With Direct Links)

These URLs open the Prometheus UI with the query pre-filled:

### Target health
```
http://localhost:9090/graph?g0.expr=up&g0.tab=1&g0.display_mode=lines&g0.show_exemplars=0&g0.range_input=1h
```

### Go goroutines graph
```
http://localhost:9090/graph?g0.expr=go_goroutines&g0.tab=0&g0.display_mode=lines&g0.show_exemplars=0&g0.range_input=1h
```

### Memory usage graph
```
http://localhost:9090/graph?g0.expr=process_resident_memory_bytes&g0.tab=0&g0.display_mode=lines&g0.show_exemplars=0&g0.range_input=1h
```

### TSDB head series
```
http://localhost:9090/graph?g0.expr=prometheus_tsdb_head_series&g0.tab=0&g0.display_mode=lines&g0.show_exemplars=0&g0.range_input=1h
```

### Ingestion rate graph
```
http://localhost:9090/graph?g0.expr=rate(prometheus_tsdb_head_samples_appended_total[1m])&g0.tab=0&g0.display_mode=lines&g0.show_exemplars=0&g0.range_input=1h
```

### Scrape duration
```
http://localhost:9090/graph?g0.expr=scrape_duration_seconds&g0.tab=0&g0.display_mode=lines&g0.show_exemplars=0&g0.range_input=1h
```

### HTTP request rate
```
http://localhost:9090/graph?g0.expr=rate(prometheus_http_requests_total[5m])&g0.tab=0&g0.display_mode=lines&g0.show_exemplars=0&g0.range_input=1h
```

---

## Discovery URLs

```
http://localhost:9090/api/v1/series?match[]=up
```
Returns: Metadata for the `up` metric series

```
http://localhost:9090/api/v1/series?match[]=prometheus_build_info
```
Returns: Metadata for build info series

```
http://localhost:9090/api/v1/labels
```
Returns: All label names across all metrics

```
http://localhost:9090/api/v1/label/job/values
```
Returns: All values for the `job` label

```
http://localhost:9090/api/v1/label/instance/values
```
Returns: All values for the `instance` label

---

## Status & Debug URLs

```
http://localhost:9090/api/v1/status/buildinfo
```
Returns: JSON build information

```
http://localhost:9090/api/v1/status/runtimeinfo
```
Returns: Runtime statistics (GC, memory, goroutines)

```
http://localhost:9090/api/v1/status/tsdb
```
Returns: TSDB statistics (head stats, cardinality)

```
http://localhost:9090/api/v1/status/flags
```
Returns: All command-line flags and values

```
http://localhost:9090/api/v1/status/config
```
Returns: Currently loaded configuration as YAML

```
http://localhost:9090/api/v1/status/walreplay
```
Returns: WAL replay progress (if starting up)

---

## Complete List of All 400+ Metric Names

To see every metric available on this machine:

```powershell
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/label/__name__/values" -UseBasicParsing
```

Or in browser:
```
http://localhost:9090/api/v1/label/__name__/values
```

### Categories of metrics available:

| Category | Prefix | Count |
|----------|--------|-------|
| Go Runtime | `go_*` | ~60 |
| Process | `process_*` | ~7 |
| Prometheus API | `prometheus_api_*`, `prometheus_http_*` | ~15 |
| Prometheus Engine | `prometheus_engine_*` | ~10 |
| Prometheus Storage | `prometheus_tsdb_*` | ~80 |
| Prometheus WAL | `prometheus_tsdb_wal_*` | ~15 |
| Prometheus Scrape | `scrape_*` | ~5 |
| Prometheus Targets | `prometheus_target_*` | ~40 |
| Prometheus Discovery | `prometheus_sd_*` | ~30 |
| Prometheus Rules | `prometheus_rule_*` | ~10 |
| Connection Tracking | `net_conntrack_*` | ~7 |
| Notifications | `prometheus_notifications_*` | ~4 |
| Templates | `prometheus_template_*` | ~2 |
| Treecache | `prometheus_treecache_*` | ~2 |
| **Total** | | **~400+** |

---

## Using the Autocomplete Feature

When you type in the expression box at http://localhost:9090/graph, Prometheus shows an autocomplete dropdown:

![Prometheus Autocomplete](docs/images/prometheus-autocomplete.png)

### How to use it:

1. **Type a few letters** — e.g., type `up` or `go_`
2. **See matching metrics** — dropdown shows all metrics containing those letters
3. **Use arrow keys** — `↑` `↓` to navigate the list
4. **Press Tab or Enter** — to autocomplete the selected metric
5. **Type `rate(` or `sum(`** — to see aggregation functions
6. **Type `{`** — after a metric name to see available labels

### Example autocomplete workflow:

```
1. Type: pro
2. See: prometheus_build_info, prometheus_engine_*, prometheus_http_*, etc.
3. Arrow down to: prometheus_tsdb_head_series
4. Press Tab → metric name autocompletes
5. Click Execute
```

---

## PowerShell One-Liners

Run these in PowerShell for quick checks:

```powershell
# Check if Prometheus is responding
Test-NetConnection -ComputerName localhost -Port 9090

# Get all metric names
(Invoke-WebRequest -Uri "http://localhost:9090/api/v1/label/__name__/values" -UseBasicParsing).Content | ConvertFrom-Json | Select-Object -ExpandProperty data

# Check target health
(Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query?query=up" -UseBasicParsing).Content | ConvertFrom-Json | Select-Object -ExpandProperty data | Select-Object -ExpandProperty result

# Get build info
(Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query?query=prometheus_build_info" -UseBasicParsing).Content | ConvertFrom-Json | Select-Object -ExpandProperty data | Select-Object -ExpandProperty result

# Count total metrics
((Invoke-WebRequest -Uri "http://localhost:9090/api/v1/label/__name__/values" -UseBasicParsing).Content | ConvertFrom-Json | Select-Object -ExpandProperty data).Count

# Check memory usage in MB
[math]::Round(((Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query?query=process_resident_memory_bytes" -UseBasicParsing).Content | ConvertFrom-Json | Select-Object -ExpandProperty data | Select-Object -ExpandProperty result | Select-Object -ExpandProperty value)[1] / 1MB, 2)
```

---

## Troubleshooting URLs

If something isn't working, check these:

```
http://localhost:9090/targets
```
- Should show `prometheus` job with State = **UP**

```
http://localhost:9090/api/v1/targets
```
- JSON version of targets page

```
http://localhost:9090/status
```
- Shows uptime, version, reload status

```
http://localhost:9090/flags
```
- Verify `--config.file` and `--storage.tsdb.path` are correct

---

## External Access (From Other Devices)

If you want to access Prometheus from another device on your network:

1. Find your machine's IP:
   ```powershell
   ipconfig
   ```

2. Replace `localhost` with your IP:
   ```
   http://192.168.1.100:9090
   ```

3. Make sure Windows Firewall allows port 9090

---

## Summary

| Type | URL Pattern | Count |
|------|-------------|-------|
| Web UI Pages | `/`, `/graph`, `/targets`, etc. | ~12 |
| API Endpoints | `/api/v1/*` | ~14 |
| Query URLs | `?query=*` | 400+ metrics |
| Range Queries | `?query=*&start=*&end=*` | Unlimited |
| Status APIs | `/api/v1/status/*` | ~6 |
| Direct Graph Links | `/graph?g0.expr=*` | Unlimited |

**Total unique testable URLs**: 400+ metrics × multiple query types = **thousands of combinations**

Start with: http://localhost:9090/graph?g0.expr=up
