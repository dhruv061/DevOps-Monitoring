# Docker Logs in Grafana with Loki

## Flow Overview
Promtail gather logs from logs through Docker SDK → Promtail sends logs to Loki → Show Loki logs in Grafana

## File Overview

### 1. docker_promtail_setup.sh
- This file installs Promtail (Version - 3.3.2) and configures promtail file for Docker logs.

**Note:**
1. Make sure you have changed `<LOKI-END-POINT>` in below line:
```yaml
clients:
  - url: <LOKI-END-POINT>/loki/api/v1/push
```

2. Make sure you have changed "replacement" as you wish in below line but do not change "target_label". Make sure it is "environment" because in multi docker environment dashboard it uses this variable for filtration.

### 2. promtail-local-config.yaml
- This file is for gathering Docker logs.

**Note:**
Make sure you have changed `<LOKI-END-POINT>` in below line:
```yaml
clients:
  - url: <LOKI-END-POINT>/loki/api/v1/push
```

### 3. Simple-Docker-Logs-Grafana-Dashboard.json
- Grafana dashboards that show all container logs
- If you have multiple servers and each server has multiple containers, then this dashboard shows all containers in one place

**Note:**
- Change `<LOKI_ID>` with your actual Loki ID

![Simple Docker Logs Dashboard][IMG-1]

### 4. Multi-environment-Docker-Logs-Grafana-Dashboard.json
- Grafana dashboard that shows all container logs based on environment
- For example, if you have 2 EC2 servers:
  - One for staging (with 2 containers)
  - One for production (with 2 containers)
- Then this dashboard shows all container logs based on selected environment

**Note:**
- Change `<LOKI_ID>` with your actual Loki ID

![Multi-Environment Docker Logs Dashboard][IMG-2]

[IMG-1]: ./images/simple-docker-logs-dashboard.png
[IMG-2]: ./images/multi-environment-docker-logs-dashboard.png