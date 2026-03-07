# SovereignKey — Complete User Guide

**"Your keys. Your money. Your communications. Zero trust required."**

This guide takes you from unboxing to fully operational.  
No technical background required.

---

## What Is SovereignKey?

SovereignKey (SK) is a USB drive that runs **SpawnOS** — a private, sovereign
operating system. You plug it into any computer and it boots into a completely
separate, secure environment. When you unplug it, the computer goes back to
normal. Nothing is left behind.

**What it gives you:**
- **Privacy** — All internet traffic goes through Tor automatically. No one
  can see what you're doing or where you're connecting.
- **Bitcoin sovereignty** — Store and manage Bitcoin without trusting anyone
  else's software or servers.
- **Sovereign communications** — Message other SpawnOS users without any
  central service. Works even without internet.
- **AI assistance** — Spawn, your personal AI agent, runs locally on the device.

---

## Part 1: First Boot

### Step 1 — Boot from the USB

1. Insert the SovereignKey USB into any computer.
2. Restart the computer.
3. When the screen goes black, press the **boot menu key** for your computer:

   | Brand | Key |
   |-------|-----|
   | Dell | F12 |
   | HP | F9 or Esc |
   | Lenovo | F12 or F1 |
   | ASUS | F8 or Esc |
   | Mac | Hold Option (⌥) |

4. Select the USB drive from the menu.
5. The SpawnOS boot menu appears. Press **Enter** to select **SpawnOS**.

> **If the USB doesn't appear in the boot menu:**  
> Go into BIOS settings (usually F2 or Delete at startup). Make sure  
> **Secure Boot is OFF** and the **boot order has USB first**.

### Step 2 — The LUKS Passphrase (Persistence Mode)

If your SK is set up with persistent storage (most are), you'll see:

```
Please unlock disk sdb2_crypt: _
```

Enter your **LUKS passphrase** and press Enter. This decrypts your personal
data partition. If you don't know it, it was set when your SK was configured —
check your setup documentation.

> **Amnesic mode:** If you boot without entering a passphrase (or press Escape),
> SpawnOS boots in amnesic mode. Nothing saves between sessions. Good for
> maximum privacy on shared computers.

### Step 3 — You're In

You'll see the SpawnOS desktop. Tor starts automatically. Your Bitcoin wallets
and communications are ready.

---

## Part 2: The SpawnOS Desktop

### What You'll See

When SpawnOS boots, the XFCE desktop appears with a panel at the bottom.
Key items:

- **SpawnOS Comms Hub** — The communications centre (Nostr, BitChat, WhiteNoise)
- **Sparrow Wallet** — Bitcoin wallet (full-featured, connects to your own node)
- **Electrum** — Lightweight Bitcoin wallet
- **Terminal** — Command line (for advanced use)
- **Files** — File manager

### Opening the Communications Hub

Click **SpawnOS Comms Hub** in the applications menu or on the desktop.

A dark-themed window opens with five sections in the left sidebar:
- **Overview** — System status at a glance
- **Nostr** — Decentralized messaging
- **BitChat** — Bluetooth mesh messaging
- **WhiteNoise** — Anonymous LAN/internet mesh
- **Pair Devices** — Connect to another SpawnOS user
- **Settings** — Network mode and privacy controls

---

## Part 3: Communications Overview

SpawnOS gives you three independent ways to communicate. Each one works
differently and suits different situations.

### The Three Comms Layers

```
BITCHAT      — Bluetooth only. Talks directly to nearby devices.
               No WiFi, no internet, no infrastructure needed at all.
               Range: ~10-30 metres.

NOSTR        — Uses the internet (or your local network).
               Each SpawnOS device runs its own relay.
               Two SK devices on the same WiFi can message each other
               without any internet at all.
               When internet is available, connects to public relays too.

WHITENOISE   — Uses your local network.
               Automatically finds other SpawnOS devices on the same WiFi.
               Also works over Tor when internet is available.
```

> **Rule of thumb:**  
> Same room, no internet → use BitChat  
> Same WiFi network → use Nostr or WhiteNoise  
> Different cities, over internet → use Nostr (via Tor)

---

## Part 4: First-Time Comms Setup

### Step 1 — Start All Services

Open **SpawnOS Comms Hub** and click **▶ Start All Services** on the Overview tab.

You'll see the three status cards update:
- Nostr: **● Running** (green)
- BitChat: depends on Bluetooth hardware being present
- WhiteNoise: **● Running** (green)

### Step 2 — Create a Nostr Identity

Click **Nostr** in the sidebar.

Under **Identities**, click **+ New**. Enter a name for this identity (e.g.
"main") and click **Create**.

Your identity is a cryptographic keypair. It's stored encrypted on your SK.
No email, no phone number, no account — just a key.

### Step 3 — Note Your Device Address

On the **Overview** page, at the top bar you'll see:

```
spawnos-device  ·  192.168.1.47
```

That IP address (e.g. `192.168.1.47`) is how other SpawnOS devices on the
same network find yours. Share it with the person you want to connect with.

---

## Part 5: Pairing Two SpawnOS Devices

This is the one-step way to connect all three comms layers at once.

### On Your Device

1. Click **Pair Devices** in the sidebar.
2. Enter the other person's IP address (they get it from their Overview page).
3. Click **⊕ Pair Now**.

SpawnOS automatically:
- Adds their Nostr relay to your relay list
- Connects WhiteNoise peers
- Shows you how to set up Bluetooth for BitChat

### On Their Device

They do the same thing with *your* IP address. Pairing is mutual — both sides
need to pair with each other.

> **Once paired, you can:**  
> - Publish Nostr notes that appear on their relay  
> - Send WhiteNoise messages directly  
> - Chat via BitChat if Bluetooth is enabled

---

## Part 6: Using Nostr

### Publish a Message

1. Click **Nostr** in the sidebar.
2. In the **Publish a Note** box, type your message.
3. Click **Publish**.

Your message is signed with your private key and sent to all connected relays
— including the paired devices' relays. No central server is involved.

### Add a Public Relay (Optional)

To reach Nostr users outside your local network (over internet via Tor):

1. Click **+ Add Relay**
2. Enter a public relay URL, e.g. `wss://relay.damus.io`
3. Click **Add**

Your message will now be sent to both local SpawnOS relays and the public relay.

### Start/Stop the Local Relay

Your SK runs a Nostr relay that other SpawnOS devices connect to. It starts
automatically. To manage it manually:

- Click **Start Relay** to start
- Click **Stop** to stop

When the relay is running, the address shown (e.g. `ws://192.168.1.47:7777`)
is what other users add as a relay to connect to you.

---

## Part 7: Using BitChat (Bluetooth)

BitChat is pure Bluetooth mesh messaging. It requires no internet, no WiFi,
no router — just two devices within Bluetooth range of each other.

### Enable Bluetooth

1. Click **BitChat** in the sidebar.
2. Click **Enable Bluetooth**.
3. Click **Start BitChat**.

The status card shows **● Active** and **● Running** when ready.

### Find Nearby Devices

Click **🔍 Scan for Devices**. SpawnOS scans for 10 seconds and lists any
Bluetooth devices found nearby.

If another SpawnOS device is nearby with BitChat enabled, it will appear.
Click **Select** next to their device to fill in the address.

### Send a Message

1. Select a device from the scan list (or type their Bluetooth address manually)
2. Type your message in the box
3. Press **Send** or hit Enter

> **Privacy note:** BitChat by default encrypts messages between known peers.
> It works best when both devices have scanned for each other at least once.

---

## Part 8: Using WhiteNoise

WhiteNoise automatically discovers other SpawnOS devices on the same network
using mDNS (the same technology Apple devices use to find printers).

### Start the Daemon

1. Click **WhiteNoise** in the sidebar.
2. Click **Start WhiteNoise**.

The daemon starts and advertises your device as `SpawnOS-[hostname]` on the
local network.

### Find Peers

Click **⟳ Refresh Peer List**. SpawnOS scans the local network for other
SpawnOS devices using mDNS.

Found devices appear in the **Discovered Peers** list with their IP.
Click **Select** to choose one.

### Send a Message

1. Select a peer from the list
2. Type your message
3. Click **Send**

---

## Part 9: Bitcoin with SpawnOS

### Launching Wallets

Open a terminal and type:

```bash
sk launch sparrow      # Full-featured wallet, connects to your Bitcoin node
sk launch electrum     # Lightweight wallet
sk launch seedsigner   # SeedSigner air-gap signing emulator
```

Or click the wallet icons in the applications menu. All wallets launch through
Tor automatically — they never connect to the internet without Tor.

### Storing a Seed Phrase

Your seed phrase is the master key to your Bitcoin. SpawnOS stores it encrypted.

```bash
sk bitcoin seed store mywallet
```

You'll be asked to type your seed phrase (hidden, like a password). Type it
twice to confirm. It's encrypted with AES-256 and saved to the LUKS-encrypted
persistence partition.

> **CRITICAL:** In amnesic mode, seeds stored this session will be lost on
> reboot. Always back up to your encrypted backup before shutting down.

### Viewing a Stored Seed

```bash
sk bitcoin seed show mywallet
```

You'll be warned that the seed will appear on screen and asked to confirm.
Run `clear` in the terminal when done.

### Listing Stored Seeds

```bash
sk bitcoin seed list
```

Shows names only — never exposes the actual seed.

### Backing Up Everything

```bash
sk bitcoin backup
```

Creates an encrypted `.tar.gpg` backup of all Bitcoin data. Copy it to an
external encrypted drive before shutting down.

### Connecting to Your Own Bitcoin Node

If you run your own Bitcoin Core node, SpawnOS connects directly to it:

```bash
sk node setup
```

Walk through the wizard. You'll need your node's:
- IP address or .onion address
- RPC username
- RPC password

After setup, Sparrow and Electrum are automatically configured to use your node.

---

## Part 10: The Spawn AI Agent

Spawn is your personal AI assistant that runs locally on SpawnOS.

### Starting the Agent

```bash
sk agent start
sk agent status
```

### Sending Tasks

```bash
sk agent task "summarise the news"
sk agent task "check my Bitcoin node sync status"
sk agent task "help me draft a Nostr post about sovereignty"
```

### Checking Logs

```bash
sk agent logs
```

---

## Part 11: Privacy Controls

### Check Your Tor Status

```bash
sk tor status
```

Shows whether Tor is running and whether traffic is actually routing through it.

### Get a New Tor Identity

```bash
sk tor newid
```

Gets you a new Tor circuit — changes the path your traffic takes. Use this
when you want to start fresh with a new apparent origin.

### Randomize Your MAC Address

```bash
sk mac randomize
```

Changes your network hardware identifier to a random value. This prevents
the WiFi router from identifying your device by its MAC address. SpawnOS does
this automatically on boot, but you can also do it manually.

### In the GUI

Go to **Settings** in the Comms Hub:
- Change network mode (Auto / Tor Only / Clearnet)
- New Tor Identity button
- MAC Randomize button

---

## Part 12: Network Modes

SpawnOS has three modes for how it handles internet connections:

### Auto (Default — Recommended)

Tor is used whenever available. If Tor is temporarily unavailable, SpawnOS
falls back to a direct connection with a clear warning. You never get stuck.

### Tor Only

Maximum privacy. If Tor goes down, connections fail rather than leaking to
clearnet. Recommended only for advanced users who understand the tradeoff.

### Clearnet Only

Direct connections. No Tor. Use only on a fully trusted private network where
you don't need anonymity.

**To change:**
```bash
sk node set CONNECTION_MODE auto
sk node set CONNECTION_MODE tor
sk node set CONNECTION_MODE clearnet
```

Or use the **Settings** tab in the Comms Hub.

---

## Part 13: System Status

### Full System Check

```bash
sk status
```

Shows everything: Tor status, firewall, Spawn agent, Bitcoin tools.

### Communications Status

```bash
sk comms status
```

Shows Nostr relay, BitChat, and WhiteNoise status with your device's IP.

---

## Part 14: Shutting Down Safely

### Normal Shutdown

SpawnOS handles shutdown safely. When you shut down:
- Session data is cleared
- GPG agent is stopped
- Tor circuits are closed

Click the power button in the panel, or:
```bash
sudo shutdown -h now
```

### Emergency Wipe

If you ever need to immediately clear all session data:
```bash
sk wipe
```

This clears session data, kills all sensitive processes, and can optionally
clear the persistence partition.

---

## Part 15: Troubleshooting

### "USB not booting"

- Try the **SpawnOS (Failsafe)** option in the GRUB boot menu
- In BIOS: turn **Secure Boot OFF**, set USB as first boot device
- Re-flash the USB if needed (see `docs/BUILD_ON_KALI.md`)

### "Tor is not running"

```bash
sudo systemctl start tor
sk tor status
```

If Tor still fails, check `/var/log/tor/log` for details.

### "Nostr relay not connecting"

Make sure both devices are on the same network and the relay is running:
```bash
sk comms nostr relay status
```

If the other device can't reach your relay, check that your firewall is
running:
```bash
sudo systemctl status spawnos-firewall
```

### "BitChat won't start"

```bash
sk comms bitchat enable
sk comms bitchat start
```

If Bluetooth hardware is not detected, the device may not have a Bluetooth
radio (some laptops don't). BitChat requires hardware Bluetooth.

### "sk: command not found"

The `sk` alias may not be set up. Use `spawnkey` instead, or:
```bash
sudo ln -sf /usr/local/bin/spawnkey /usr/local/bin/sk
```

### "Permission denied when running sk"

```bash
sudo chmod +x /usr/local/bin/spawnkey
sudo chmod +x /usr/local/bin/spawn-comms
```

---

## Quick Reference Card

```
COMMUNICATIONS
  sk comms status              Full status of all three comms layers
  sk comms pair <IP>           Pair with another SpawnOS device
  sk comms nostr keygen        Create a Nostr identity
  sk comms nostr publish <msg> Publish a Nostr note
  sk comms bitchat enable      Enable Bluetooth
  sk comms bitchat scan        Find nearby devices
  sk comms whitenoise status   WhiteNoise mesh status

BITCOIN
  sk launch sparrow            Open Sparrow wallet (Tor-routed)
  sk launch electrum           Open Electrum (Tor-routed)
  sk bitcoin seed store <name> Save an encrypted seed phrase
  sk bitcoin seed list         List saved seeds
  sk bitcoin seed show <name>  Show a seed (prompts confirmation)
  sk bitcoin backup            Encrypted backup of all Bitcoin data
  sk node setup                Connect to your own Bitcoin node

PRIVACY
  sk tor status                Check Tor is working
  sk tor newid                 New Tor circuit
  sk mac randomize             Randomize MAC address
  sk wipe                      Emergency session clear

SYSTEM
  sk status                    Full system status
  sk agent start               Start Spawn AI agent
  sk agent task "<text>"       Send a task to Spawn
  sk init                      First-time setup wizard
```

---

## Glossary

**LUKS** — Linux encryption for your persistence partition. The passphrase
you enter at boot.

**Tor** — The Onion Router. Routes your internet traffic through multiple
servers worldwide so it can't be traced back to you.

**Nostr** — A decentralized social and messaging protocol. Your identity is
a key, not an account. No platform can ban or silence you.

**BitChat** — Bluetooth mesh messaging. Devices form a network directly with
each other, like a walkie-talkie network.

**WhiteNoise** — A libp2p-based anonymous messaging protocol that finds peers
automatically on local networks using mDNS.

**Relay** — In Nostr, a server that stores and forwards messages. Your SK
runs its own relay. Other SpawnOS devices connect to yours and vice versa.

**Seed phrase** — A set of 12 or 24 words that is the master key to a Bitcoin
wallet. Never store it anywhere digitally unless encrypted. SpawnOS encrypts
it for you.

**Amnesic mode** — Booting without persistence. Nothing saves. Leaves no
trace on the host computer.

**mDNS** — A protocol for discovering devices on a local network without a
central DNS server. SpawnOS uses it to auto-discover other SpawnOS devices.

---

*SovereignKey — Your device. Your keys. Your sovereignty.*
