# SpawnOS Communications Layer — Plan

## Overview

SpawnOS will include a native communications layer as a fourth pillar:

```
SpawnOS
├── AI Layer        (Spawn agent)
├── Bitcoin Layer   (wallets, node, seeds)
├── Privacy Layer   (Tor, firewall, MAC)
└── Comms Layer     (Nostr, BitChat, WhiteNoise)  ← this doc
```

---

## The Three Tools and Why They Belong

### Nostr
**What it is:** A decentralized, censorship-resistant protocol for social
communication and data publishing. No central server. Clients connect to
relays of their choosing. Identity is a keypair — no account, no email.

**Why it fits SpawnOS:** Your Nostr identity is a private key, stored the same
way Bitcoin seeds are stored — AES-256 encrypted via `spawn-bitcoin`. Clients
connect to relays over Tor. If a relay bans you, you reconnect to another.
No platform can silence you.

**What we install:** `gossip` (Rust desktop client, privacy-focused) as the
primary client. Also `nostril` CLI for agent-level Nostr posting.

**Tor note:** Nostr relay connections are fast (WebSocket). Tor latency is
acceptable for messaging. Default is Tor; clearnet fallback available if
needed (same `auto` mode as `spawn-node`).

**Future:** A custom SpawnOS Nostr client is planned — potentially built by
Spawn subagents. This will be tracked as a separate project once Spawn's
subagent capabilities are mature enough to handle a full frontend build.

---

### BitChat
**What it is:** Bluetooth mesh encrypted messaging — no internet required.
Repo: https://github.com/permissionlesstech/bitchat

**Why it fits SpawnOS:** This is the offline-first, infrastructure-free
communications option. When Tor is down, internet is down, or you're in a
situation where you can't trust any network — BitChat works over Bluetooth
between nearby devices. It's the comms layer that works when everything else
fails. Pairs perfectly with SpawnOS's sovereignty mission.

**What we install:** The BitChat daemon and CLI, plus a simple XFCE desktop
launcher.

**Important:** BitChat uses Bluetooth — SpawnOS will need Bluetooth hardware
support baked in (bluez package + firmware). Already in our package list via
firmware-linux-nonfree. We add `bluez` and `bluetooth` explicitly.

**No Tor involvement:** BitChat is local mesh — Tor is irrelevant here. It
works completely independently of any network connectivity.

---

### WhiteNoise
**What it is:** Anonymous peer-to-peer messaging over libp2p. No central
relays. Nodes discover each other via DHT. End-to-end encrypted.

**Why it fits SpawnOS:** WhiteNoise is the middle ground — internet-based but
with no central infrastructure (unlike Nostr's relays). When combined with
Tor, it becomes extremely difficult to trace. Best used for longer-form
private communication where Nostr's public-relay model isn't appropriate.

**Tor note:** WhiteNoise over Tor can be slow due to the combination of DHT
peer discovery and Tor latency. We default to `auto` mode (Tor preferred,
clearnet fallback). Pure Tor-only mode is available for maximum privacy.

---

## Implementation Plan

### Phase 1 — BitChat (next build)
Bluetooth mesh. No Tor complications. Clean install.
- Add `bluez`, `bluetooth`, `python3-dbus` to package list
- Hook `0040-comms-tools.hook.chroot` installs BitChat
- `spawn-comms` CLI: `sk comms bitchat start|stop|status|send`
- Desktop entry in XFCE launcher

### Phase 2 — Nostr (build after BitChat)
- Install `gossip` desktop client and `nostril` CLI
- `sk comms nostr keygen` — generates Nostr keypair, stores encrypted
- `sk comms nostr publish <text>` — posts via Tor
- Key stored alongside Bitcoin seeds in `spawn-bitcoin` encrypted storage

### Phase 3 — WhiteNoise (after Nostr)
- Install WhiteNoise daemon
- Wire through `spawn-tor-gateway` (auto mode)
- `sk comms whitenoise send|receive|status`

### Phase 4 — Unified spawn-comms (after Phase 3)
Single `spawn-comms` daemon that manages all three protocols, with
Spawn agent able to orchestrate comms via `sk agent task "send nostr note: ..."`.

---

## Key Design Decisions

**Nostr keys and Bitcoin keys share the same storage system.** Both are
encrypted AES-256 via `spawn-bitcoin`. This is intentional — in Bitcoin
culture, your Nostr identity and your Bitcoin identity are often the same
keypair (nsec/npub = private/public key). SpawnOS supports this natively.

**BitChat has no Tor dependency** — this is a feature, not a bug. It means
comms still work when Tor is blocked, surveilled, or unavailable. This is
the resilience layer.

**No clearnet-only fallback for Nostr in `tor` mode** — Nostr relay connections
in `tor` mode will fail gracefully and notify the user rather than leaking
clearnet traffic. `auto` mode handles the fallback.

**Future Nostr app:** The plan is to eventually build a custom SpawnOS-native
Nostr client. This will likely be built by Spawn subagents when that capability
is ready. The architecture (keypair in spawn-bitcoin storage, relay config in
/etc/spawn/config.yml, Tor routing via spawn-tor-gateway) is being designed
now so the subagent build has a clean foundation to work from.
