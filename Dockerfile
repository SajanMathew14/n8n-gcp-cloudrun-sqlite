FROM docker.n8n.io/n8nio/n8n:latest

USER root
RUN mkdir -p /mnt/data && chown node:node /mnt/data
COPY startup.sh /home/node/startup.sh
RUN chmod +x /home/node/startup.sh

USER node
ENTRYPOINT ["/home/node/startup.sh"]