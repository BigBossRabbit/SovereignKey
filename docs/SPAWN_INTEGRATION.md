# Spawn Integration Guide

## How Spawn Runs in SpawnOS

Spawn is a first-class OS service — not an app, not a script. It has its own
system user, systemd service, and all network traffic is forced through Tor
at the NAT level before it can touch a wire.

## Syncing Your Spawn Agent

```bash
# From the SovereignKey directory:
scripts/sync-spawn.sh

# Custom path:
SPAWN_SOURCE=/path/to/spawn scripts/sync-spawn.sh
```

This reads from `~/Documents/Spawn/spawn` and copies into the build tree.
It never writes back to your Spawn source.

## How spawn-daemon Finds Your Agent

Checks in order:
1. `/home/spawn/.spawn/agent/main.py` (persistent storage — live updates)
2. `/home/spawn/.spawn/agent/index.js`
3. `/usr/local/share/spawnos/agent/main.py` (baked into ISO)
4. Stub mode — keeps service alive, logs instructions

## CLI Quick Reference

```bash
sk agent start               # Start Spawn
sk agent stop                # Stop Spawn
sk agent status              # Status
sk agent logs                # Live logs
sk agent task "do this"      # Send task
sk status                    # Full system status
sk bitcoin seed store mykey  # Encrypt a seed
sk bitcoin seed list         # List seeds
sk launch sparrow            # Launch Sparrow (Tor)
```

## Environment Variables in spawn.service

| Variable | Value |
|---|---|
| `SPAWN_CONFIG` | `/etc/spawn/config.yml` |
| `SPAWN_DATA_DIR` | `/home/spawn/.spawn` |
| `http_proxy` | `socks5://127.0.0.1:9050` |
| `https_proxy` | `socks5://127.0.0.1:9050` |
| `SPAWN_TOR_MODE` | `true` |

## Updating Spawn Without Rebuilding ISO

On a running SpawnOS system:
```bash
# Copy new Spawn code to persistent storage
cp -r /path/to/updated/spawn /home/spawn/.spawn/agent/
sk agent restart
```
