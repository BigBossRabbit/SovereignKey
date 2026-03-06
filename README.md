![SpawnOS](./Logo/SK%20Logo.jpeg)

# SpawnOS

> *The Swiss Army Knife — evolved. Now it thinks.*

SpawnOS is a custom Debian-based, privacy-hardened, USB-bootable operating system with the **Spawn AI agent** running natively at the OS level. All traffic exits through Tor. All Bitcoin tools connect through your own pruned node. No third-party wrappers. No donation prompts. No external branding. Ever.

---

## What SpawnOS Is

Three things fused into one sovereign platform:

**Sovereign AI** — Spawn runs as a system daemon from boot. All agent traffic is cryptographically forced through Tor. No clearnet fallback.

**Bitcoin Sovereignty** — Full self-custody stack connecting to your own pruned Bitcoin Core node: PSBT signing, multi-sig, encrypted offline seed storage, inheritance planning. All Tor-routed.

**Private Computing** — Amnesic mode leaves no trace. Persistent mode uses LUKS encryption. All traffic exits Tor. IPv6 disabled. MAC randomized every boot. DNS over Tor.

---

## Who It's For

Privacy-conscious individuals, Bitcoin holders, developers, and anyone who wants to own their digital future — especially the next generation inheriting this world.

---

## What's Included

| Layer | What's Included |
|-------|----------------|
| **AI** | Spawn agent daemon, `spawnkey` CLI (`sk`), Tor-tunneled agent requests |
| **Bitcoin** | Sparrow Wallet, Electrum, Liana, SeedSigner Emulator, native encrypted seed storage |
| **Node** | Pruned Bitcoin Core node connection layer (Tor-routed, Sparrow + Electrum integrated) |
| **Privacy** | Tor routing (kernel-level nftables), DNS-over-Tor, MAC randomization, IPv6 disabled |
| **Security** | Nmap, Wireshark, Aircrack-ng, KeePassXC, AppArmor, hardened sysctl |
| **Dev Tools** | VSCodium, Python 3, Node.js, Git |
| **Boot Modes** | Standard (LUKS persistence) or Amnesic (RAM only, no trace) |

---

## Boot Instructions

1. Flash SpawnOS to USB: `scripts/install-sk.sh /dev/sdX`
2. Power off, insert USB, power on
3. Press your boot menu key (table below)
4. Select **Boot from USB**
5. At GRUB: choose **SpawnOS** or **SpawnOS (Amnesic)**
6. Enter LUKS passphrase if using persistence
7. Spawn agent starts automatically

### First-Time Setup

```bash
spawnkey init          # Configure Spawn API endpoint, verify Tor
spawnkey status        # Confirm everything is running
```

### Quick Reference

```bash
sk agent start                    # Start Spawn daemon
sk agent task "do this"           # Send task to Spawn
sk launch sparrow                 # Sparrow Wallet (Tor + own node)
sk launch electrum                # Electrum (Tor + own node)
sk bitcoin seed store mywallet    # Encrypt and store a seed
sk bitcoin seed list              # List stored seeds
sk node status                    # Check pruned node connection
sk tor status                     # Verify Tor
sk status                         # Full system status
```

---

## Bitcoin Node Integration

SpawnOS connects all Bitcoin tools to a **pruned Bitcoin Core node** — not a third-party server.
This means Sparrow and Electrum verify their own transactions without trusting anyone else.

The connection flows through Tor:

```
Sparrow / Electrum
      ↓
spawn-node (local connection manager)
      ↓
Bitcoin Core (pruned) ← Tor hidden service
      ↓
Bitcoin network
```

Configure your node:
```bash
sk node set <onion-address>    # Set your Bitcoin Core .onion address
sk node status                  # Verify connection
```

See `docs/NODE_SETUP.md` for full pruned node setup instructions.

---

## Architecture

```
SpawnOS (Debian Bookworm base)
├── Kernel + hardened sysctl
├── nftables — Tor-only egress, default-drop
├── systemd
│   ├── spawnos-firewall.service   ← nftables before network
│   ├── tor.service                ← Tor daemon
│   ├── spawn-tor-gateway.service  ← Force Spawn through Tor
│   └── spawn.service              ← Spawn AI agent daemon
├── Spawn Layer
│   ├── /etc/spawn/config.yml
│   ├── /usr/local/bin/spawnkey (sk)
│   └── /home/spawn/.spawn/        ← encrypted persistence
└── User Layer — XFCE, Bitcoin tools, security tools
```

Full details: `docs/ARCHITECTURE.md` | `docs/SPAWN_INTEGRATION.md` | `docs/BUILD.md`

---

## Building SpawnOS

```bash
scripts/sync-spawn.sh          # Pull Spawn agent into build tree
sudo scripts/build-iso.sh      # Build ISO (20-60 min, needs Debian/Ubuntu host)
scripts/install-sk.sh /dev/sdX # Flash to USB
```

---

## Boot Menu Hotkeys

<details>
<summary>Click to expand</summary>

| Manufacturer | Key |
|---|---|
| Acer | Esc, F12, F9 |
| Asus | Esc, F8 |
| Dell | F12 |
| HP | Esc, F9 |
| Lenovo | F12, F8, F10 |
| Samsung | F12, Esc |
| Sony | F10, F11, Assist |
| Toshiba | F12 |

**Motherboards:** Asus F8 · Gigabyte F12 · MSI F11 · Intel F10 · ASRock F11 · EVGA F7

</details>

---

## Warnings

- **Apple M1/M2**: Not currently supported
- **LUKS passphrase**: Unrecoverable if forgotten — memorize it, then destroy any written copy
- **Amnesic mode**: Nothing persists after shutdown by design
- **Spawn API keys**: Store only in encrypted persistence, never in amnesic session

---

## Contributing

Issues and PRs welcome. Email: okinent@protonmail.com

## License

MIT
