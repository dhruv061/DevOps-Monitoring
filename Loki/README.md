
# Loki

### generate_pm2_promtail_config.sh
This script generates a `promtail-local-config.yaml` file that collects logs from the server and sends them to Loki. Specifically, it generates log configurations for PM2 processes.

Here’s a code chunk that is added for each PM2 process to capture both error and access logs:

```yaml
- job_name: server-3038-access
  static_configs:
  - targets:
      - localhost
    labels:
      job: server-3038-access
      __path__: /home/ubuntu/.pm2/logs/server-3038-out.log
```

You would replace the job name and path with the appropriate PM2 process details.

# Automation

This section contains two files:

1. **monitor_pm2.js**: This file monitors the state of all PM2 processes. Whenever a new PM2 process starts, this Node.js application runs the `update_pm2_promtail_config.sh` script.
   
2. **update_pm2_promtail_config.sh**: This script adds new PM2 access and error log entries to the `promtail-local-config.yaml` file. It automatically inserts the necessary code chunk for the newly added PM2 process and restarts Promtail, ensuring that logs from the new process are captured.

