FROM docker.n8n.io/n8nio/n8n:latest

USER root

# Prepare data folder
RUN mkdir -p /mnt/data && chown node:node /mnt/data

# Ensure home directory exists and copy startup script
RUN mkdir -p /home/node
COPY startup.sh /home/node/startup.sh
RUN chmod +x /home/node/startup.sh && chown node:node /home/node/startup.sh

USER node

# Expose the port that n8n will run on
EXPOSE 8080

# Set n8n environment variables for Cloud Run
ENV PORT=8080
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=8080
ENV N8N_PROTOCOL=http
ENV N8N_LOG_LEVEL=info
ENV N8N_METRICS=true

ENTRYPOINT ["/home/node/startup.sh"]
