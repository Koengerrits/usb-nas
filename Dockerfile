FROM ghcr.io/home-assistant/amd64-base:latest

WORKDIR /app
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

CMD [ "/app/run.sh" ]
