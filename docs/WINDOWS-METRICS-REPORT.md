# Windows System Metrics Monitoring Report

**Date**: 2026-05-12  
**Machine**: Windows 11 Workstation  
**Status**: ✅ CPU and System Metrics Active

---

## What Was Done

### 1. Downloaded windows_exporter

**Tool**: `windows_exporter` (formerly wmi_exporter)  
**Version**: v0.25.1  
**Source**: https://github.com/prometheus-community/windows_exporter  
**File**: `windows_exporter-0.25.1-amd64.exe`

**Download command**:
```powershell
Invoke-WebRequest -Uri "https://github.com/prometheus-community/windows_exporter/releases/download/v0.25.1/windows_exporter-0.25.1-amd64.exe" -OutFile "C:\projects\prometheus-local\windows_exporter.exe"
```

### 2. Started windows_exporter with CPU and System Collectors

**Command**:
```powershell
windows_exporter.exe --web.listen-address=:9182 --collectors.enabled=cpu,cs,logical_disk,memory,net,os,service,system,textfile
```

**Collectors enabled**:

| Collector | Metrics Provided |
|-----------|-----------------|
| `cpu` | CPU clock interrupts, DPCs, idle time, time spent per core |
| `cs` | Computer system info (hostname, processors, physical memory) |
| `logical_disk` | Disk read/write bytes, latency, queue depth, free space |
| `memory` | Available memory, cache, page faults, commit limit, pool |
| `net` | Network bytes sent/received, packets, errors per NIC |
| `os` | OS info, paging, processes, users, timezone |
| `service` | Windows service states and statuses |
| `system` | Context switches, threads, processor queue, system calls |
| `textfile` | Custom metrics from text files |

**Endpoint**: http://localhost:9182/metrics

### 3. Updated Prometheus Configuration

**File**: `config/prometheus.yml`

Added a new scrape job for windows_exporter:

```yaml
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
    metrics_path: /metrics

  - job_name: 'windows'
    static_configs:
      - targets: ['localhost:9182']
    metrics_path: /metrics
```

### 4. Restarted Prometheus with Lifecycle API

**Command**:
```powershell
prometheus.exe --config.file=config\prometheus.yml --storage.tsdb.path=data --web.listen-address=:9090 --web.enable-lifecycle
```

The `--web.enable-lifecycle` flag allows hot-reloading configuration via `POST http://localhost:9090/-/reload`.

---

## Verification Results

### Target Status

```
http://localhost:9090/api/v1/targets
```

**Result**: Both targets UP

| Job | Instance | Health | Last Scrape |
|-----|----------|--------|-------------|
| `prometheus` | localhost:9090 | up | 0.02s duration |
| `windows` | localhost:9182 | up | 1.6s duration |

### CPU Metrics Available

```
http://localhost:9090/api/v1/label/__name__/values
```

**Windows CPU metrics** (all prefixed with `windows_cpu_`):

| Metric | Description |
|--------|-------------|
| `windows_cpu_clock_interrupts_total` | Clock interrupts per core |
| `windows_cpu_core_frequency_mhz` | CPU core frequency in MHz |
| `windows_cpu_cstate_seconds_total` | Time spent in each C-state |
| `windows_cpu_dpcs_total` | Deferred Procedure Calls |
| `windows_cpu_idle_break_events_total` | Idle break events |
| `windows_cpu_interrupts_total` | Hardware interrupts |
| `windows_cpu_parking_status` | Core parking status |
| `windows_cpu_processor_mperf_total` | Processor performance counter |
| `windows_cpu_processor_performance_total` | Processor performance time |
| `windows_cpu_processor_privileged_utility_total` | Privileged mode time |
| `windows_cpu_processor_utility_total` | Total CPU utility |
| `windows_cpu_time_total` | CPU time by mode (idle, user, system) |

### Memory Metrics Available

| Metric | Description |
|--------|-------------|
| `windows_memory_available_bytes` | Available physical memory |
| `windows_memory_cache_bytes` | System cache size |
| `windows_memory_commit_limit` | Commit limit |
| `windows_memory_committed_bytes` | Committed memory |
| `windows_memory_page_faults_total` | Page faults |
| `windows_memory_pool_nonpaged_bytes` | Non-paged pool |
| `windows_memory_pool_paged_bytes` | Paged pool |

### Disk Metrics Available

| Metric | Description |
|--------|-------------|
| `windows_logical_disk_free_bytes` | Free disk space |
| `windows_logical_disk_size_bytes` | Total disk size |
| `windows_logical_disk_read_bytes_total` | Bytes read |
| `windows_logical_disk_write_bytes_total` | Bytes written |
| `windows_logical_disk_read_latency_seconds_total` | Read latency |
| `windows_logical_disk_write_latency_seconds_total` | Write latency |

### Network Metrics Available

| Metric | Description |
|--------|-------------|
| `windows_net_bytes_received_total` | Bytes received per NIC |
| `windows_net_bytes_sent_total` | Bytes sent per NIC |
| `windows_net_packets_received_total` | Packets received |
| `windows_net_packets_sent_total` | Packets sent |
| `windows_net_packets_received_errors_total` | Receive errors |

### System Metrics Available

| Metric | Description |
|--------|-------------|
| `windows_system_threads` | Active threads |
| `windows_system_context_switches_total` | Context switches |
| `windows_system_system_calls_total` | System calls |
| `windows_system_processor_queue_length` | Processor queue |

---

## How to Query CPU Usage

### Total CPU Time by Mode

```promql
windows_cpu_time_total{job="windows"}
```

Returns CPU time spent in:
- `idle`
- `interrupt`
- `dpc`
- `privileged`
- `user`

### CPU Utilization Percentage (approximate)

```promql
100 - (avg by (instance) (rate(windows_cpu_time_total{mode="idle"}[1m])) * 100)
```

### Available Memory

```promql
windows_memory_available_bytes{job="windows"}
```

### Memory Usage Percentage

```promql
100 * (1 - windows_memory_available_bytes / windows_cs_physical_memory_bytes)
```

### Disk Free Space

```promql
windows_logical_disk_free_bytes{volume="C:"}
```

### Network Traffic Rate

```promql
rate(windows_net_bytes_total[1m])
```

---

## Important: GPU Monitoring

**windows_exporter does NOT include GPU metrics by default.**

GPU monitoring on Windows requires additional tooling:

### Option 1: NVIDIA GPUs
Use the **nvidia_gpu_exporter**:
```
https://github.com/utkuozdemir/nvidia_gpu_exporter
```

### Option 2: AMD GPUs
Use **AMDMetricsExporter** or parse WMI `Win32_VideoController`.

### Option 3: Generic GPU (WMI)
Create a custom textfile collector with PowerShell:
```powershell
Get-WmiObject Win32_VideoController | Select-Object Name, AdapterRAM, VideoProcessor
```

For this setup, GPU metrics are **not yet configured** but the infrastructure is ready to add another exporter job to `prometheus.yml`.

---

## Architecture

```
Prometheus (port 9090)
    |
    |-- scrape --> localhost:9090/metrics (Prometheus self-metrics)
    |
    |-- scrape --> localhost:9182/metrics (windows_exporter)
            |
            |-- CPU metrics (per core)
            |-- Memory metrics
            |-- Disk metrics (per volume)
            |-- Network metrics (per NIC)
            |-- Service metrics
            |-- System metrics
```

---

## URLs to Monitor

| URL | What it shows |
|-----|---------------|
| http://localhost:9090/targets | Both scrape targets health |
| http://localhost:9090/graph?g0.expr=windows_cpu_time_total | CPU time per core |
| http://localhost:9090/graph?g0.expr=windows_memory_available_bytes | Available RAM |
| http://localhost:9090/graph?g0.expr=windows_logical_disk_free_bytes | Disk free space |
| http://localhost:9090/graph?g0.expr=windows_net_bytes_total | Network traffic |
| http://localhost:9182/metrics | Raw windows_exporter output |

---

## Starting on Boot

To run windows_exporter as a Windows service (like Prometheus), use NSSM:

```cmd
nssm install windows-exporter "C:\projects\prometheus-local\windows_exporter.exe"
nssm set windows-exporter AppParameters "--web.listen-address=:9182 --collectors.enabled=cpu,cs,logical_disk,memory,net,os,service,system"
nssm set windows-exporter AppDirectory "C:\projects\prometheus-local"
nssm start windows-exporter
```

---

## Summary

| Component | Status |
|-----------|--------|
| Prometheus | ✅ Running on :9090 |
| windows_exporter | ✅ Running on :9182 |
| CPU metrics | ✅ Available (per core) |
| Memory metrics | ✅ Available |
| Disk metrics | ✅ Available (per volume) |
| Network metrics | ✅ Available (per NIC) |
| Service metrics | ✅ Available |
| GPU metrics | ❌ Not configured (requires nvidia_gpu_exporter) |

**Total new metrics added**: 100+ Windows system metrics

**Next step for GPU**: Download and configure nvidia_gpu_exporter if you have an NVIDIA GPU.
