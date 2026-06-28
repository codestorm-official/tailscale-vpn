FROM alpine:3.19

# Pin a known-good Tailscale version for reproducible builds.
# Override at build time with: --build-arg TAILSCALE_VERSION=x.y.z
ARG TAILSCALE_VERSION="1.98.4"
ARG TARGETARCH="amd64"

# Runtime defaults (override these as Railway variables).
ENV TAILSCALE_HOSTNAME="tailscale-app" \
    TAILSCALE_ADDITIONAL_ARGS="--advertise-exit-node"

WORKDIR /app

RUN apk add --no-cache \
    ca-certificates \
    iptables \
    ip6tables \
    iproute2 \
    wget \
    tar

# Download only the two binaries we need, stripped into the current dir.
RUN wget -O tailscale.tgz "https://pkgs.tailscale.com/stable/tailscale_${TAILSCALE_VERSION}_${TARGETARCH}.tgz" && \
    tar xzf tailscale.tgz --strip-components=1 \
        "tailscale_${TAILSCALE_VERSION}_${TARGETARCH}/tailscale" \
        "tailscale_${TAILSCALE_VERSION}_${TARGETARCH}/tailscaled" && \
    mv tailscale tailscaled /usr/local/bin/ && \
    rm tailscale.tgz

RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

COPY start.sh .
RUN chmod +x start.sh

CMD ["./start.sh"]
