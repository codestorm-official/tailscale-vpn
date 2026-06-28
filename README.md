# Tailscale Node (Docker)

A minimal Docker image that runs a [Tailscale](https://tailscale.com) node and joins your tailnet on startup using an auth key. Once up, the machine appears in your Tailscale admin console like any other device, and can act as an [exit node](https://tailscale.com/kb/1103/exit-nodes).

It runs `tailscaled` in **userspace networking** mode, so it works in container environments without `/dev/net/tun` or the `NET_ADMIN` capability. A local **SOCKS5 / HTTP proxy on `localhost:1055`** is also exposed, letting other processes in the same container reach machines on your tailnet.

## What it does

- Joins your tailnet using a Tailscale auth key — no public ports are exposed.
- Optionally advertises itself as an exit node (enabled by default).
- Provides a `localhost:1055` proxy for outbound access to your tailnet.

## Common use cases

- **Exit node** — route traffic from your other devices out through this node. Suitable for low-bandwidth use; high-throughput exit nodes perform better with kernel networking (not available in userspace mode).
- **Private access** — reach machines on your tailnet (an internal database, API, etc.) from the same container via the `localhost:1055` proxy.
- **Secure bridge** — give a workload a stable identity inside your private network without opening public ingress.

## Configuration

| Variable | Required | Default | Description |
|---|---|---|---|
| `TAILSCALE_AUTHKEY` | Yes | — | Auth key from the Tailscale admin console. A `reusable` + `ephemeral` key is recommended. |
| `TAILSCALE_HOSTNAME` | No | `tailscale-app` | Name shown in your machine list. |
| `TAILSCALE_ADDITIONAL_ARGS` | No | `--advertise-exit-node` | Extra `tailscale up` flags. Set empty to disable exit-node mode. |
| `TAILSCALE_VERSION` | No | `1.98.4` | Build-time only; Tailscale version baked into the image. |

Generate an auth key at <https://login.tailscale.com/admin/settings/keys>. After deploying with `--advertise-exit-node`, approve the exit node under **Machines → … → Edit route settings** in the Tailscale admin console.

## Deploy

### Option 1 — One-click on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template)

> Replace the link above with your published template URL. After deploying, set `TAILSCALE_AUTHKEY` in the service variables.

### Option 2 — Run locally with Docker

Build the image:

```bash
docker build -t tailscale-node .
```

Run it:

```bash
docker run -d --name tailscale-node \
  -e TAILSCALE_AUTHKEY=tskey-auth-xxxxxxxxxxxx \
  -e TAILSCALE_HOSTNAME=my-node \
  tailscale-node
```

Check the logs to confirm it connected:

```bash
docker logs -f tailscale-node
```

You can also copy `.env.example` to `.env`, fill in your values, and run with `--env-file .env`.

## Notes

- **Persistence:** Tailscale state lives at `/var/lib/tailscale`. If the container filesystem is ephemeral, the node re-authenticates on every restart — which is why a reusable key is recommended. To keep a stable identity across restarts, mount a volume at `/var/lib/tailscale`.
- **Updating Tailscale:** set `TAILSCALE_VERSION` to any release listed at <https://pkgs.tailscale.com/stable/> and rebuild.
