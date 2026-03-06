# Node Setup — Connecting SpawnOS to Your Own Bitcoin Core Node

## Why Your Own Node

When you connect Sparrow or Electrum to a third-party server, that server can see
all your addresses, balances, and transaction history. Your own pruned node sees
nothing about you — it just gives you verified blockchain data.

SpawnOS routes all node connections through Tor by default.

## What You Need

A **pruned Bitcoin Core node** — this can be:
- On a home server (Raspberry Pi, old laptop, etc.)
- On a cloud VPS (ideally paid with Bitcoin/Monero)
- On the same machine you're running SpawnOS from (uncommon but works)

A pruned node uses ~10-15GB disk vs ~650GB for a full node. Perfect for a USB setup.

## Setting Up Bitcoin Core (on your node machine)

### Install Bitcoin Core

```bash
# On your node machine (Debian/Ubuntu)
sudo apt-get install bitcoind

# Or download from bitcoin.org and verify the signature
```

### Configure bitcoin.conf

```ini
# /etc/bitcoin/bitcoin.conf (or ~/.bitcoin/bitcoin.conf)

# Pruned node — keeps only ~10GB of chain data
prune=10000

# RPC access for Sparrow
server=1
rpcuser=spawnos
rpcpassword=CHANGE_THIS_TO_SOMETHING_STRONG
rpcbind=127.0.0.1
rpcallowip=127.0.0.1

# Tor hidden service — exposes your node as a .onion
proxy=127.0.0.1:9050
listen=1
bind=127.0.0.1
onlynet=onion
```

### Get your .onion address

```bash
# After starting bitcoind with Tor enabled:
bitcoin-cli getnetworkinfo | grep onion
```

### Install Electrs (personal Electrum server on top of your node)

```bash
# Electrs indexes your node for Electrum wallet queries
# https://github.com/romanz/electrs
cargo install electrs

# Or use Electrum Personal Server (lighter alternative)
# https://github.com/chris-belcher/electrum-personal-server
```

## Connecting SpawnOS to Your Node

On your SpawnOS USB, once booted:

```bash
sk node setup
```

This runs an interactive wizard asking for:
- Your Bitcoin Core `.onion` address and RPC credentials
- Your Electrum server `.onion` address and port

It then automatically configures both Sparrow and Electrum to use your node.

## Verify the Connection

```bash
sk node status
```

Should show:
```
Bitcoin Core RPC (youraddress.onion:8332): ✓ Connected
  Chain: main | Blocks: 895432 | Pruned: true

Electrum server (yourelec.onion:50001): ✓ Reachable
```

## Updating Node Config

```bash
# Change a single field:
sk node set BITCOIN_RPC_ONION yournewaddress.onion

# Full reconfiguration:
sk node setup

# Re-apply current config to wallets (after manual edit):
sk node apply
```

## Security Notes

- Node config is stored at `/home/spawn/.spawn/bitcoin/node.conf` — on the LUKS-encrypted persistence partition
- RPC password is never stored in plaintext in wallet configs — only in the node.conf
- All connections route through Tor — your node's IP is never revealed to wallet software
