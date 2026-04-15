#!/bin/sh

mkdir -p /var/lib/tailscale

tailscaled \
    --state=/var/lib/tailscale/tailscaled.state \
    --socket=/var/run/tailscale/tailscaled.sock \
    --tun=userspace-networking \
    --socks5-server=localhost:1055 \
    --outbound-http-proxy-listen=localhost:1055 &

echo "Waiting for tailscaled socket..."
until [ -S /var/run/tailscale/tailscaled.sock ]; do
    sleep 0.5
done

echo "Tailscale is starting up..."
until tailscale up \
    --authkey="${TAILSCALE_AUTHKEY}" \
    --hostname="${TAILSCALE_HOSTNAME}" \
    --advertise-exit-node \
    ${TAILSCALE_ADDITIONAL_ARGS}
do
    echo "Retrying tailscale up..."
    sleep 2
done

echo "Tailscale is up and running!"

wait