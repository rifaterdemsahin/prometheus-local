@echo off
:: Wait for services to stabilize (optional)
timeout /t 5 /nobreak > NUL

:: Open Prometheus
start http://localhost:9090

:: Open Grafana
start http://localhost:3000
