FROM docker.n8n.io/n8nio/n8n:latest

USER root
RUN mkdir -p /mnt/data && chown node:node /mnt/data
COPY --chmod=0755 startup.sh /home/node/startup.sh
USER node

ENTRYPOINT ["/home/node/startup.sh"]