# SpawnOS Architecture

## Overview

SpawnOS is a custom Debian-based live OS (Bookworm / Debian 12) built with `live-build`.
It is NOT a Tails wrapper. We implement Tails' philosophy ourselves at every layer.

## Boot Sequence

```
BIOS/UEFI → GRUB → Linux kernel
  └─ systemd
       ├─ spawnos-firewall.service  (nftables Tor-only routing — before network)
       ├─ tor.service               (Tor daemon)
       ├─ spawn-tor-gateway.service (NAT rules forcing Spawn through Tor)
       ├─ spawn.service             (Spawn AI agent daemon)
       └─ lightdm                   (XFCE desktop)
```

## Key File Locations

| Path | Purpose |
|------|---------|
| `/etc/spawn/config.yml` | Spawn + OS configuration |
| `/etc/spawn/spawn.env` | Spawn environment variables |
| `/usr/local/bin/spawnkey` | Main CLI (`sk` alias) |
| `/usr/local/bin/spawn-daemon` | Spawn agent launcher |
| `/usr/local/bin/spawn-bitcoin` | Native Bitcoin storage manager |
| `/usr/local/share/spawnos/agent/` | Spawn agent code (from sync-spawn.sh) |
| `/home/spawn/.spawn/` | Spawn runtime data (encrypted persistence) |
| `/etc/nftables.d/spawnos.conf` | Firewall + Tor routing |
| `/etc/tor/torrc` | Tor configuration |

## Security Model

- nftables default-drop with transparent Tor proxy
- AppArmor MAC enforcement
- Hardened sysctl (ASLR, no ICMP redirects, TCP hardening)
- IPv6 disabled (no leak vector)
- MAC randomization on every boot
- DNS resolved over Tor (no leaks)

## Persistence vs Amnesic

**Standard boot**: LUKS-encrypted partition on USB, Spawn state persists.
**Amnesic boot**: RAM only, nothing survives shutdown.
