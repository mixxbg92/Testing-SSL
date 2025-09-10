FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    openssl \
    msmtp \
    ca-certificates \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY cert_checker.sh websites.conf msmtprc ./

RUN dos2unix /app/cert_checker.sh /app/msmtprc /app/websites.conf \
    && chmod 600 /app/msmtprc \
    && mkdir -p /root/.config/msmtp \
    && cp /app/msmtprc /root/.config/msmtp/config \
    && chmod +x /app/cert_checker.sh

CMD ["./cert_checker.sh"]
