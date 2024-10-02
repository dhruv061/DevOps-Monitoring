#!/bin/bash

# Path to Promtail configuration file
PROMTAIL_CONFIG="/etc/promtail-local-config.yaml"

# Path to the unified log file where script activity will be recorded
LOG_FILE="/home/ubuntu/Promtail_Info/update_promtail_config-log.log"

# Create the log file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
  touch "$LOG_FILE"
  echo "Log file created at $LOG_FILE" >> "$LOG_FILE"
fi

# Function to log script actions with date and time
log_action() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  local process_name=$1
  echo "$timestamp - Process: $process_name" >> "$LOG_FILE"
}

# Function to append the log path for the process to the Promtail configuration
append_log_to_promtail() {
  process_name=$1
  out_log=$2
  err_log=$3

  # Check if logs for this process are already present in the Promtail config
  if ! grep -q "${process_name}-access" "$PROMTAIL_CONFIG"; then
    # Log the action
    log_action "$process_name - Appending logs"

    # Append the new log configuration to Promtail config
    cat <<EOF >> "$PROMTAIL_CONFIG"
#------------------------------------------
- job_name: ${process_name}-access
  static_configs:
  - targets:
      - localhost
    labels:
      server: game-server
      __path__: ${out_log}
#------------------------------------------
- job_name: ${process_name}-err
  static_configs:
  - targets:
      - localhost
    labels:
      server: game-server
      __path__: ${err_log}
EOF

    # Log successful append
    log_action "$process_name - (access: $out_log, error: $err_log)"

    # Optionally, reload Promtail after appending
    sudo systemctl restart promtail  
    log_action "$process_name - restarted Promtail."
  fissss
}

# Fetch the current process details using pm2 and append their logs if not already present
pm2 jlist | jq -r '.[] | select(.pm2_env.pm_out_log_path != null and .pm2_env.pm_err_log_path != null) | 
"\(.name):\(.pm2_env.pm_out_log_path):\(.pm2_env.pm_err_log_path)"' | while IFS=: read -r process_name out_log err_log; do
  append_log_to_promtail "$process_name" "$out_log" "$err_log"
done
