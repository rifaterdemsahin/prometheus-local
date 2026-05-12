# Accessing Prometheus

## Main UI

| URL | Description |
|-----|-------------|
| http://localhost:9090 | Prometheus web UI home |
| http://localhost:9090/graph | Expression browser / query UI |
| http://localhost:9090/targets | Scrape target health and status |
| http://localhost:9090/service-discovery | Service discovery status |
| http://localhost:9090/alerts | Active alerts |
| http://localhost:9090/status | Runtime & build information |
| http://localhost:9090/flags | Command-line flags in use |
| http://localhost:9090/config | Currently loaded configuration |
| http://localhost:9090/rules | Recording and alerting rules |

## Metrics Endpoints

| URL | Description |
|-----|-------------|
| http://localhost:9090/metrics | Prometheus's own metrics (PromQL source) |
| http://localhost:9090/api/v1/query | Instant query API |
| http://localhost:9090/api/v1/query_range | Range query API |
| http://localhost:9090/api/v1/series | Series metadata API |
| http://localhost:9090/api/v1/labels | Label names API |

## API Examples

### Instant Query
```bash
curl 'http://localhost:9090/api/v1/query?query=up'
```

### Range Query (last 5 minutes)
```bash
curl 'http://localhost:9090/api/v1/query_range?query=up&start=2024-01-01T00:00:00Z&end=2024-01-01T00:05:00Z&step=15s'
```

### List All Metrics
```bash
curl 'http://localhost:9090/api/v1/label/__name__/values'
```

## Useful PromQL Queries

Once the UI is open at http://localhost:9090/graph, try these:

| Query | Description |
|-------|-------------|
| `up` | Health of all scrape targets (1 = up, 0 = down) |
| `prometheus_build_info` | Version and build details |
| `rate(prometheus_tsdb_head_samples_appended_total[1m])` | Ingestion rate |
| `prometheus_tsdb_storage_blocks_bytes` | Disk usage by TSDB |
| `scrape_duration_seconds` | Time taken per scrape |
| `scrape_samples_scraped` | Number of samples scraped per target |

## Changing the Port

If you cannot use port 9090, change it in the NSSM service parameters:

```cmd
nssm set prometheus-service AppParameters "--config.file=\"C:\projects\prometheus-local\config\prometheus.yml\" --storage.tsdb.path=\"C:\projects\prometheus-local\data\" --web.listen-address=:9091"
nssm restart prometheus-service
```

Then access via:
```
http://localhost:9091
```

## External Access (Other Devices)

By default Prometheus binds to **all interfaces** (`0.0.0.0:9090`), so other devices on your network can reach it via your machine's IP address:

```
http://<your-pc-ip>:9090
```

To verify your PC's IP:
```powershell
ipconfig
```

If you want to restrict it to localhost only, update NSSM parameters:
```cmd
nssm set prometheus-service AppParameters "--config.file=\"...\" --storage.tsdb.path=\"...\" --web.listen-address=127.0.0.1:9090"
nssm restart prometheus-service
```

## Troubleshooting Access Issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| `This site can't be reached` | Service not running | `nssm start prometheus-service` |
| `Connection refused` | Wrong port / firewall | Check port in `nssm dump` and Windows Firewall rules |
| Blank page | Browser cache / JS error | Hard refresh (`Ctrl+F5`) or try incognito mode |
| Slow loading | Large TSDB / high cardinality | Check `prometheus_tsdb_head_series` metric |
