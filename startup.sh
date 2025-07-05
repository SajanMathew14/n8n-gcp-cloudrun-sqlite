#!/bin/bash
set -e

# Set default values
PORT=${PORT:-8080}
N8N_DB_SQLITE_FILE=${N8N_DB_SQLITE_FILE:-/mnt/data/database.sqlite}

echo "Starting n8n startup script..."
echo "Port: ${PORT}"
echo "Database file: ${N8N_DB_SQLITE_FILE}"
echo "Host: ${N8N_HOST:-0.0.0.0}"

# Wait for volume mount to be available
echo "Checking volume mount availability..."
for i in {1..30}; do
    if [ -d "/mnt/data" ] && [ -w "/mnt/data" ]; then
        echo "Volume mount is ready"
        break
    fi
    echo "Waiting for volume mount... (attempt $i/30)"
    sleep 2
done

# Verify we can write to the data directory
if [ ! -w "/mnt/data" ]; then
    echo "ERROR: Cannot write to /mnt/data directory"
    exit 1
fi

# Create database directory if it doesn't exist
mkdir -p "$(dirname "$N8N_DB_SQLITE_FILE")"

# Set additional n8n environment variables for Cloud Run
export N8N_HOST=0.0.0.0
export N8N_PORT=$PORT
export N8N_PROTOCOL=http
export N8N_LOG_LEVEL=info
export N8N_METRICS=true
export N8N_DISABLE_UI=false
export N8N_BASIC_AUTH_ACTIVE=false

echo "Launching n8n on ${N8N_HOST}:${PORT}"
echo "Database: ${N8N_DB_SQLITE_FILE}"

# Launch n8n in foreground
exec n8n start
