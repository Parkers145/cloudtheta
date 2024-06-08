#!/bin/sh

# Function to log messages with timestamps
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Set the directory where the files will be downloaded
TARGET_DIR="/etc/theta"

# Ensure the target directory exists
log "Ensuring target directory exists: $TARGET_DIR"
mkdir -p $TARGET_DIR
if [ $? -ne 0 ]; then
  log "Failed to create target directory: $TARGET_DIR"
  exit 1
fi

# Download Mainnet Guardian Configuration
log "Starting download of Mainnet Guardian Configuration"
GUARDIAN_CONFIG_URL=$(curl -k -s 'https://mainnet-data.thetatoken.org/config?is_guardian=true')
if [ $? -ne 0 ]; then
  log "Failed to retrieve Mainnet Guardian Configuration URL"
  exit 1
fi

log "Downloading Mainnet Guardian Configuration from $GUARDIAN_CONFIG_URL"
curl -k -o $TARGET_DIR/config.yaml $GUARDIAN_CONFIG_URL
if [ $? -ne 0 ]; then
  log "Failed to download Mainnet Guardian Configuration"
  exit 1
fi
log "Successfully downloaded Mainnet Guardian Configuration to $TARGET_DIR/config.yaml"

# Download Mainnet Snapshot
log "Starting download of Mainnet Snapshot"
SNAPSHOT_URL=$(curl -k -s https://mainnet-data.thetatoken.org/snapshot)
if [ $? -ne 0 ]; then
  log "Failed to retrieve Mainnet Snapshot URL"
  exit 1
fi

log "Downloading Mainnet Snapshot from $SNAPSHOT_URL"
wget -O $TARGET_DIR/snapshot $SNAPSHOT_URL
if [ $? -ne 0 ]; then
  log "Failed to download Mainnet Snapshot"
  exit 1
fi
log "Successfully downloaded Mainnet Snapshot to $TARGET_DIR/snapshot"

log "All tasks completed successfully"
