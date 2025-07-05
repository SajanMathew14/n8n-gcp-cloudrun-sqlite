#!/bin/bash

# Simple health check script for n8n
# This can be used for local testing or debugging

PORT=${PORT:-8080}
HOST=${N8N_HOST:-0.0.0.0}

echo "Checking n8n health at http://${HOST}:${PORT}"

# Wait for n8n to be ready
for i in {1..30}; do
    if curl -f -s "http://${HOST}:${PORT}/healthz" > /dev/null 2>&1; then
        echo "n8n is healthy!"
        exit 0
    elif curl -f -s "http://${HOST}:${PORT}" > /dev/null 2>&1; then
        echo "n8n is responding on main endpoint!"
        exit 0
    fi
    echo "Waiting for n8n to be ready... (attempt $i/30)"
    sleep 2
done

echo "n8n health check failed"
exit 1
