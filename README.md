# SovereignKey — SpawnOS Edition

![SpawnOS](./Logo/SK%20Logo.jpeg)

> *From promise to power.* The SovereignKey has evolved.

**SpawnOS** is a Debian-based, privacy-hardened, USB-bootable operating system that integrates the **Spawn AI agent system** at the OS level — built on the foundation of SovereignKey's original mission of digital sovereignty, Bitcoin self-custody, and anonymous computing.

Think Kali Linux's architecture (custom Debian live-build ISO, purpose-built tooling) fused with Tails OS's privacy model (Tor-routed, amnesic by default) — and powered by **Spawn**, your own AI agent system running natively at the system service level.

---

## What Changed

| Feature | SovereignKey (Before) | SpawnOS (Now) |
|---|---|---|
| Base OS | Tails OS (pre-built) | Custom Debian live-build |
| AI Integration | None | Spawn agent daemon (systemd) |
| Privacy | Tor via Tails | Tor-routed at kernel/netfilter level |
| Persistence | Tails Encrypted Storage | Encrypted LUKS partition |
| Security tooling | None | Full Kali-style toolkit optional |
| Bitcoin tools | Pre-installed | Pre-installed + Spawn-managed |
| Build process | USB flash of Tails image | Custom ISO via `live-build` |

---

## Core Philosophy

SpawnOS is **three things fused into one**:

1. **Sovereign** — You own the hardware, the OS, the keys, the agents. Nothing phones home.
2. **Private** — All traffic routes through Tor by default. Amnesic mode available. LUKS encryption on persistence.
3. **Intelligent** — Spawn runs as a system-level AI agent daemon, enabling autonomous, privacy-first AI workflows natively on the OS.

---

## What's Included

### AI Layer
- **Spawn Agent Daemon** — Runs as a `systemd` service at boot, managed via `spawnctl`
- **Spawn CLI** — `spawnkey` command for agent orchestration
- **Tor-tunneled AI requests** — All Spawn API calls route through Tor by default

### Bitcoin Sovereignty Tools
- **Sparrow Wallet** — Full-feature self-custody Bitcoin wallet
- **Electrum** — Lightweight, reliable Bitcoin wallet
- **Liana Wallet** — Bitcoin wallet with inheritance/recovery protections
- **SeedSigner Emulator** — Offline seed generation and PSBT signing
- **CipherStick (Bails)** — Censorship-resistant Bitcoin storage

### Privacy Infrastructure
- **Tor** — All traffic routed through Tor (netfilter rules at boot)
- **Firewall** — Strict nftables ruleset, deny-by-default
- **DNS-over-Tor** — No DNS leaks
- **MAC randomization** — On every interface, every boot

### Security Tooling
- **Nmap** — Network discovery
- **Wireshark** — Traffic analysis
- **Aircrack-ng** — WiFi security auditing
- **Metasploit** — Penetration testing framework (optional install)
- **VSCodium** — Telemetry-free code editor

### Developer Tools
- **Python 3** with pip
- **Node.js** + npm
- **Git**
- **Docker** (optional, for Spawn containers)

---

## Quick Start

### Boot from USB

1. Flash SpawnOS ISO to USB: `scripts/install-sk.sh /dev/sdX`
2. Boot from USB (see PC Hotkeys below)
3. At boot menu: select **SpawnOS** or **SpawnOS (Amnesic)**
4. Unlock persistent storage when prompted (LUKS passphrase)
5. Spawn agent starts automatically at login

### First-Time Spawn Setup

```bash
spawnkey init
spawnkey config set tor_mode true
spawnkey agent start
spawnkey status
```

### Bitcoin Workflow

```bash
# Launch Sparrow (Tor-routed)
spawnkey launch sparrow

# Or via Spawn agent
spawnkey agent task "open sparrow wallet"
```

---

## Building the ISO

Requirements: Debian/Ubuntu host with `live-build` installed.

```bash
cd live-build
./build.sh
# Output: ../spawnos-<version>-amd64.iso
```

See `docs/BUILD.md` for full instructions including cross-architecture builds.

---

## Architecture

```
SpawnOS
├── Debian Stable (base)
│   ├── Kernel + hardened sysctl
│   ├── nftables (Tor-routing firewall)
│   └── systemd
│       ├── spawn.service          ← Spawn AI agent daemon
│       ├── tor.service            ← Tor daemon
│       ├── spawn-tor-gateway.service ← Routes Spawn through Tor
│       └── bitcoin-tools.service  ← Bitcoin app environment
├── Spawn Agent Layer
│   ├── /etc/spawn/config.yml      ← Spawn configuration
│   ├── /usr/local/bin/spawnkey    ← CLI interface
│   └── /usr/local/share/spawnos/ ← Spawn OS integration modules
└── User Environment
    ├── XFCE desktop (lightweight, customized)
    ├── Bitcoin tools (Sparrow, Electrum, Liana, SeedSigner)
    └── Security tools (Nmap, Wireshark, VSCodium)
```

---

## Spawn Integration

Spawn runs as a first-class OS citizen:

- **Boot**: `spawn.service` starts after `tor.service` 
- **Networking**: Spawn agent traffic is forced through Tor via `spawn-tor-gateway.service`
- **Persistence**: Spawn state lives in encrypted LUKS partition at `/home/spawn/`
- **CLI**: `spawnkey` wraps the Spawn agent API for terminal use
- **Desktop**: Spawn dashboard available via app launcher

See `docs/SPAWN_INTEGRATION.md` for the full architecture.

---

## PC Boot Hotkeys

<details>
<summary>Click to expand</summary>

| Manufacturer | Boot Menu Key |
|---|---|
| Acer | Esc, F12, F9 |
| Asus | Esc, F8 |
| Dell | F12 |
| HP | Esc, F9 |
| Lenovo | F12, F8, F10 |
| Samsung | F12, Esc |
| Sony | F10, F11, Assist |
| Toshiba | F12 |

**Motherboards:**

| Manufacturer | Boot Menu Key |
|---|---|
| Asus | F8 |
| Gigabyte | F12 |
| MSI | F11 |
| Intel | F10 |
| ASRock | F11 |

</details>

---

## Contributing

- Submit issues and PRs on GitHub
- Email: okin@okinent.org
- All contributions welcome: code, docs, translations, testing

---

## License

MIT — See LICENSE file.

---

## Warnings

- **Apple M1/M2**: Not currently supported (Debian live-build limitation)
- **Always backup** data before writing to USB
- **Passphrase**: If you forget your LUKS passphrase, data is unrecoverable
- **Spawn API keys**: Store only in encrypted persistence volume, never in amnesic session

---

*SpawnOS — The Swiss Army Knife evolved. Now it thinks.*
