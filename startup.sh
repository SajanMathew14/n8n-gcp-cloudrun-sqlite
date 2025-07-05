#!/bin/bash
set -e

# Set default values
PORT=${PORT:-8080}
N8N_DB_SQLITE_FILE=${N8N_DB_SQLITE_FILE:-/mnt/data/database.sqlite}

echo "=== n8n Cloud Run Startup Script ==="
echo "Timestamp: $(date)"
echo "Port: ${PORT}"
echo "Database file: ${N8N_DB_SQLITE_FILE}"
echo "Host: ${N8N_HOST:-0.0.0.0}"
echo "Memory info: $(cat /proc/meminfo | grep MemTotal)"
echo "Disk space: $(df -h /mnt/data 2>/dev/null || echo 'Volume not yet mounted')"

# Wait for volume mount to be available with exponential backoff
echo "Checking volume mount availability..."
for i in {1..15}; do
    if [ -d "/mnt/data" ] && [ -w "/mnt/data" ]; then
        echo "Volume mount is ready at attempt $i"
        break
    fi
    echo "Waiting for volume mount... (attempt $i/15)"
    if [ $i -eq 15 ]; then
        echo "ERROR: Volume mount failed after 15 attempts (30 seconds)"
        echo "Directory listing of /mnt:"
        ls -la /mnt/ || echo "Cannot list /mnt directory"
        echo "Checking if /mnt/data exists but is not writable:"
        ls -la /mnt/data || echo "/mnt/data does not exist"
        exit 1
    fi
    sleep 2
done

# Verify we can write to the data directory
if [ ! -w "/mnt/data" ]; then
    echo "ERROR: Cannot write to /mnt/data directory"
    echo "Directory permissions:"
    ls -la /mnt/data
    exit 1
fi

# Create database directory if it doesn't exist
echo "Creating database directory..."
mkdir -p "$(dirname "$N8N_DB_SQLITE_FILE")"
echo "Database directory created: $(dirname "$N8N_DB_SQLITE_FILE")"

# Test database file creation
echo "Testing database file access..."
touch "$N8N_DB_SQLITE_FILE" || {
    echo "ERROR: Cannot create database file at $N8N_DB_SQLITE_FILE"
    exit 1
}
echo "Database file access confirmed"

# Set additional n8n environment variables for Cloud Run
export N8N_HOST=0.0.0.0
export N8N_PORT=$PORT
export N8N_PROTOCOL=http
export N8N_LOG_LEVEL=info
export N8N_METRICS=true
export N8N_DISABLE_UI=false
export N8N_BASIC_AUTH_ACTIVE=false
export N8N_SKIP_WEBHOOK_DEREGISTRATION_SHUTDOWN=true

echo "=== Final Configuration ==="
echo "N8N_HOST: ${N8N_HOST}"
echo "N8N_PORT: ${N8N_PORT}"
echo "N8N_PROTOCOL: ${N8N_PROTOCOL}"
echo "N8N_DB_SQLITE_FILE: ${N8N_DB_SQLITE_FILE}"
echo "N8N_LOG_LEVEL: ${N8N_LOG_LEVEL}"

echo "=== Starting n8n ==="
echo "Command: n8n start"
echo "Timestamp: $(date)"

# Launch n8n in foreground
exec n8n start
