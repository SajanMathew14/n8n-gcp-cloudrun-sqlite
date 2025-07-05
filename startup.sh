#!/bin/bash
set -e

echo "Launching n8n on port ${PORT:-8080}, DB at ${N8N_DB_SQLITE_FILE}"

# Launch n8n in foreground listening on the required port
n8n start --port="${PORT:-8080}"