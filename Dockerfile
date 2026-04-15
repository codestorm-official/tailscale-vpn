FROM alpine:3.19

ARG TAILSCALE_VERSION="1.58.2" 
ENV TAILSCALE_HOSTNAME="tailscale-app"
ENV TAILSCALE_ADDITIONAL_ARGS="--advertise-exit-node"

WORKDIR /app

RUN apk add --no-cache \
    ca-certificates \
    iptables \
    ip6tables \
    iproute2 \
    wget \
    tar

RUN wget https://pkgs.tailscale.com/stable/tailscale_${TAILSCALE_VERSION}_amd64.tgz && \
    tar xzf tailscale_${TAILSCALE_VERSION}_amd64.tgz --strip-components=1 && \
    rm tailscale_${TAILSCALE_VERSION}_amd64.tgz && \
    mv tailscale tailscaled /usr/local/bin/

RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

COPY start.sh .
RUN chmod +x start.sh

CMD ["./start.sh"]