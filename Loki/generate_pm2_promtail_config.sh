#!/bin/bash

# Node.js version required
NODE_VERSION="v20.11.1"

# Path to the new Promtail configuration file
PROMTAIL_CONFIG_FILE="/home/ubuntu/promtail-local-config.yaml"

# Path to PM2 log files
PM2_LOG_PATH="/home/ubuntu/.pm2/logs"

# Loki URL (replace with your own Loki server URL)
LOKI_URL="http://13.202.66.139:3100/loki/api/v1/push"

# Load NVM if it's installed
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    # This loads nvm
    source "$HOME/.nvm/nvm.sh"
elif [[ -s "/usr/local/nvm/nvm.sh" ]]; then
    # For systems where nvm is installed in /usr/local
    source "/usr/local/nvm/nvm.sh"
else
    echo -e "❌ NVM is not installed! Please install NVM first. 🚫"
    exit 1
fi

# Check if Node.js v20.11.1 is installed via NVM
if ! nvm ls $NODE_VERSION &>/dev/null; then
  # If Node.js v20.11.1 is not installed, ask the user whether they want to install it
  echo -e "\n"  # Add space
  echo -e "⚠️ Node.js ${NODE_VERSION} is not installed. ⚠️"
  echo -e "\n"  # Add space
  read -p "Do you want to install Node.js ${NODE_VERSION}? (y/n) " choice
  if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    echo -e "\n"  # Add space
    echo -e "\n⚙️ Installing Node.js ${NODE_VERSION}... Please wait! ⚙️"
    nvm install ${NODE_VERSION}
    nvm use ${NODE_VERSION}
    echo -e "\n"  # Add space
    echo -e "🚀 Node.js ${NODE_VERSION} installed and activated! ✅"
  else
    echo -e "\n"  # Add space
    echo -e "🚫 Mission aborted. You chose not to install Node.js ${NODE_VERSION}. ❌"
    exit 1
  fi
else
  # If Node.js v20.11.1 is installed but not active, switch to it
  CURRENT_NODE_VERSION=$(nvm current)
  if [[ "$CURRENT_NODE_VERSION" != "$NODE_VERSION" ]]; then
    echo -e "\n"  # Add space
    echo -e "⚠️ Node.js ${NODE_VERSION} is installed but not active. Switching now... ⚙️"
    echo -e "\n"  # Add space
    nvm use ${NODE_VERSION}
    echo -e "\n"  # Add space
    echo -e "✅ Node.js ${NODE_VERSION} is now active. 🎉"
  else
    echo -e "\n"  # Add space
    echo -e "✅ Node.js ${NODE_VERSION} is already active. Continuing... 🎉"
  fi
fi

echo -e "\n"  # Add space

# Check if jq is installed, if not, install it with cool messages
if ! command -v jq &> /dev/null; then
  echo -e "\n"  # Add space
  echo -e "🔍 jq not found! Preparing to install... 🚀"
  sudo apt-get update -y && echo -e "\n 🛠️ System update completed. Proceeding with jq installation... ⏳"
  sudo apt-get install -y jq && echo -e "\n ✅ jq installed successfully! 🎉"
else
  echo -e "\n"  # Add space
  echo -e "✅ jq is already installed. Skipping installation... 🎉"
fi

echo -e "\n"  # Add space

# Check if PM2 is installed
if ! command -v pm2 &> /dev/null; then
  echo -e "❌ PM2 is not installed! Please install PM2 to proceed. 🚫"
  exit 1
else
  echo -e "✅ PM2 is installed. Continuing... 🚀"
fi

# Header of the Promtail configuration file
cat <<EOL > "$PROMTAIL_CONFIG_FILE"
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /data/loki/positions.yaml

clients:
  - url: ${LOKI_URL}

scrape_configs:
EOL

# Get all PM2 process names and IDs
pm2 jlist | jq -r '.[] | .name + " " + (.pm2_env.pm_id|tostring)' | while read -r name id; do
  # Construct paths for error and output logs
  err_log="${PM2_LOG_PATH}/${name}-error.log"
  out_log="${PM2_LOG_PATH}/${name}-out.log"

  # Add a separator before each job configuration
  echo "#------------------------------------------" >> "$PROMTAIL_CONFIG_FILE"

  # Add job configuration for error logs
  cat <<EOL >> "$PROMTAIL_CONFIG_FILE"
- job_name: ${name}-err
  static_configs:
  - targets:
      - localhost
    labels:
      job: ${name}-err
      server: game-server
      __path__: ${err_log}
EOL

  # Add a separator between error and access log sections
  echo "#------------------------------------------" >> "$PROMTAIL_CONFIG_FILE"

  # Add job configuration for access logs
  cat <<EOL >> "$PROMTAIL_CONFIG_FILE"
- job_name: ${name}-access
  static_configs:
  - targets:
      - localhost
    labels:
      job: ${name}-access
      server: game-server
      __path__: ${out_log}
EOL

done

# Check if Promtail configuration was successfully generated
if [[ $? -eq 0 ]]; then
  echo "-------------------------------------------------------------------"
  echo -e "| 🎉 🚀 Promtail configuration file generated successfully! ✅ 🎉 |"
  echo "-------------------------------------------------------------------"
else
  echo -e "❌ Something went wrong while generating the Promtail configuration. Please check the script! 🚫"
fi


