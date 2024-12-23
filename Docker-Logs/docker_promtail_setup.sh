#!/bin/bash

# Define colored output for better readability and beautified messages
echo_success() {
  echo -e "\e[1;32m\n-------------------------\n[SUCCESS]\e[0m $1\n-------------------------\n"
}

echo_info() {
  echo -e "\e[1;34m\n-------------------------\n[INFO]\e[0m $1\n-------------------------\n"
}

echo_error() {
  echo -e "\e[1;31m\n-------------------------\n[ERROR]\e[0m $1\n-------------------------\n"
}

# Step 1: Update the system
echo_info "Updating the system..."
sudo apt update -y && sudo apt install unzip -y && echo_success "System updated and unzip installed." || echo_error "Failed to update system or install unzip."

# Step 2: Download and install Promtail
echo_info "Downloading Promtail..."
curl -LO https://github.com/grafana/loki/releases/download/v3.3.2/promtail-linux-amd64.zip && echo_success "Promtail downloaded." || echo_error "Failed to download Promtail."

echo_info "Installing Promtail..."
unzip promtail-linux-amd64.zip && \
  sudo mv promtail-linux-amd64 /usr/local/bin/promtail && \
  rm promtail-linux-amd64.zip && echo_success "Promtail installed successfully." || echo_error "Failed to install Promtail."

# Step 3: Verify Promtail installation
echo_info "Verifying Promtail installation..."
promtail --version && echo_success "Promtail version: $(promtail --version)" || echo_error "Failed to verify Promtail installation."

# Step 4: Create Promtail configuration file
echo_info "Creating Promtail configuration file..."
CONFIG_FILE="/etc/promtail-local-config.yaml"
sudo tee $CONFIG_FILE > /dev/null <<EOL
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /data/loki/positions.yaml

clients:
  - url: <LOKI-END-POINT>/loki/api/v1/push

scrape_configs:
  - job_name: 'docker'
    docker_sd_configs:
      - host: "unix:///var/run/docker.sock"
        refresh_interval: 3s
    relabel_configs:
      - source_labels: [__meta_docker_container_name]
        target_label: container_name
      - source_labels: [__meta_docker_container_id]
        target_label: container_id
      - source_labels: [__meta_docker_container_image]
        target_label: container_image
      # Add custom labels here
      - target_label: environment
        replacement: stag

EOL

[ -f "$CONFIG_FILE" ] && echo_success "Promtail configuration file created at $CONFIG_FILE." || echo_error "Failed to create Promtail configuration file."

# Step 5: Create a service file for Promtail
echo_info "Creating Promtail service file..."
SERVICE_FILE="/etc/systemd/system/promtail.service"
sudo tee $SERVICE_FILE > /dev/null <<EOL
[Unit]
Description=Promtail service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/promtail -config.file /etc/promtail-local-config.yaml

[Install]
WantedBy=multi-user.target
EOL

[ -f "$SERVICE_FILE" ] && echo_success "Promtail service file created at $SERVICE_FILE." || echo_error "Failed to create Promtail service file."

# Step 6: Create "/data/loki/positions.yaml" Directory
echo_info "Creating /data/loki Directory......"
cd 
sudo mkdir -p /data/loki/

# Step 7: Reload systemd and start Promtail service
echo_info "Reloading systemd and starting Promtail service..."
sudo systemctl daemon-reload && sudo systemctl start promtail.service && echo_success "Promtail service started." || echo_error "Failed to start Promtail service."

# Step 8: Check Promtail service status
echo_info "Checking Promtail service status..."
systemctl status promtail.service | grep -q 'active (running)' && echo_success "Promtail service is active and running." || echo_error "Promtail service failed to start. Check logs for details."

exit 0
