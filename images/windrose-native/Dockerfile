FROM --platform=linux/amd64 debian:trixie-slim

LABEL org.opencontainers.image.title="Windrose Native Linux Pterodactyl Runtime"
LABEL org.opencontainers.image.description="Pterodactyl-compatible runtime for the official native Windrose dedicated server payload."
LABEL org.opencontainers.image.source="https://github.com/Kalanur/pterodactyl-eggs"
LABEL org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        ca-certificates \
        libcurl4 \
        netcat-traditional \
        procps \
        python3 \
        tini \
        xdg-user-dirs \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --home-dir /home/container --shell /bin/bash container \
    && rm -rf /var/tmp/R5 \
    && ln -s /home/container/R5/Saved/.windrose-var-tmp /var/tmp/R5

COPY --chmod=0755 pterodactyl-entrypoint.sh /entrypoint.sh
COPY --chmod=0755 windrose-start.sh /usr/local/bin/windrose-start
COPY --chmod=0755 windrose-configure.py /usr/local/bin/windrose-configure

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

STOPSIGNAL SIGINT
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
