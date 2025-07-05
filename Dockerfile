FROM docker.n8n.io/n8nio/n8n:latest

USER root

# Prepare data folder
RUN mkdir -p /mnt/data && chown node:node /mnt/data

# Copy startup helper script
COPY startup.sh /home/node/startup.sh
RUN chmod +x /home/node/startup.sh

USER node

ENTRYPOINT ["/home/node/startup.sh"]