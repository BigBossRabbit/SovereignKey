# SpawnOS First Boot

## What Happens at Boot

1. GRUB menu — choose **SpawnOS** or **SpawnOS (Amnesic)**
2. Firewall activates, Tor connects, MAC randomizes
3. Enter LUKS passphrase if using persistence
4. XFCE desktop loads
5. Spawn agent starts automatically

## First-Time Setup

```bash
spawnkey init
spawnkey status
```

## Verify

```bash
sk status
# Should show: Tor running, firewall active, Spawn agent running
```

## Launch Bitcoin Tools

```bash
sk launch sparrow      # Sparrow Wallet
sk launch electrum     # Electrum
sk launch liana        # Liana
sk launch seedsigner   # SeedSigner Emulator
```

## Store a Seed Phrase

```bash
sk bitcoin seed store mywallet
# Prompts for seed, encrypts with AES-256, stores on LUKS persistence
```

## Change LUKS Passphrase

```bash
sudo cryptsetup luksChangeKey /dev/disk/by-label/SPAWNOS_PERSISTENCE
```

If you forget this passphrase, your data is permanently unrecoverable.
