FROM docker.n8n.io/n8nio/n8n:latest

USER root
RUN mkdir -p /mnt/data && chown node:node /mnt/data
USER node

COPY startup.sh /home/node/startup.sh
RUN chmod +x /home/node/startup.sh

ENTRYPOINT ["/home/node/startup.sh"]