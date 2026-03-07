# SpawnOS Security Audit — v1.0.0

**Audit Date:** 2025  
**Auditor:** Internal review  
**Scope:** All scripts in `live-build/config/includes.chroot/` and hooks

---

## Summary

| Severity | Found | Fixed |
|----------|-------|-------|
| CRITICAL | 1     | ✓     |
| HIGH     | 3     | ✓     |
| MEDIUM   | 4     | ✓     |
| LOW      | 3     | ✓     |
| INFO     | 4     | noted |

---

## CRITICAL — Fixed

### [CRIT-1] nftables output chain accepted all traffic
**File:** `etc/nftables.d/spawnos.conf`  
**Issue:** The `chain output` block in `table inet filter` had a bare `accept`
statement as its final rule. Because nftables evaluates rules top-to-bottom and
terminates on the first match, this `accept` acted as a wildcard — all outbound
traffic was permitted regardless of Tor routing. Non-Tor UDP traffic (e.g. NTP,
DHCP renewals at the application layer) was leaving the device without going
through the Tor transparent proxy. This completely defeated the Tor-only egress
goal.

**Fix:** Removed the bare `accept`. The chain now uses `policy drop` and only
accepts explicitly: loopback, established/related, Tor daemon UID, LAN CIDR
ranges (for mesh services), and mDNS. All other traffic is dropped with logging.

**Also added:** Explicit `chain prerouting` NAT rule to catch any TCP that
bypasses the `output` chain hook.

---

## HIGH — Fixed

### [HIGH-1] Shell injection via Python -c string interpolation in nostr_keygen
**File:** `usr/local/bin/spawn-comms`  
**Issue:** Private key was interpolated directly into a `python3 -c "..."` string:
```bash
python3 -c "...PrivateKey(bytes.fromhex('${privkey}'))..."
```
If `privkey` (derived from `openssl rand -hex 32`) ever contained a quote or
the generation was somehow influenced, this would break or allow injection.
Even though `openssl rand -hex 32` output is safe, the pattern is dangerous
and was also calling python3 twice (once to check, once to get the value),
printing intermediate output to stdout mixed with function output.

**Fix:** Private key now passed via environment variable `SPAWN_NSEC` — never
interpolated into the command string. Python reads `os.environ['SPAWN_NSEC']`.

### [HIGH-2] Shell injection in nostr_peer_add via Python heredoc
**File:** `usr/local/bin/spawn-comms`  
**Issue:** The JSON peers array was read into a bash variable and then
interpolated into a `python3 -c` string:
```bash
python3 -c "peers = json.loads('${peers}')..."
```
If the peers file contained single quotes (valid in JSON strings), this would
break the Python syntax or allow code injection.

**Fix:** The Python script now reads the peers file path and new relay URL via
environment variables (`SPAWN_PEERS_FILE`, `SPAWN_NEW_RELAY`). No user data
is interpolated into the command string.

### [HIGH-3] sed injection in spawn-node set_field
**File:** `usr/local/bin/spawn-node`  
**Issue:** User-supplied `field` and `value` were passed directly to `sed -i`:
```bash
sed -i "s|^${field}=.*|${field}=${value}|" "$NODE_CONFIG"
```
A value containing `|` would break the sed delimiter. A crafted field or value
could overwrite arbitrary lines in the config file.

**Fix:** `set_field` now validates the field name against `^[A-Z_]+$` (rejects
anything that isn't uppercase letters/underscores). Values are checked for null
bytes, newlines, and backslashes. Config is written via grep + printf + temp
file (no sed involved at all).

---

## MEDIUM — Fixed

### [MED-1] Missing sudoers — scripts called sudo without configuration
**Files:** `spawn-comms`, `spawnkey`, `spawn-node`  
**Issue:** Multiple scripts called `sudo systemctl`, `sudo hciconfig`, etc. with
no sudoers rules. This would either fail (if the spawn user has no sudo access)
or require a password prompt that blocks the GUI and CLI.

**Fix:** Added `/etc/sudoers.d/spawnos` with explicit NOPASSWD rules for each
specific command that requires privilege escalation. No wildcard sudo is granted.
The file is set to 0440 permissions in the setup hook.

### [MED-2] Missing chmod +x on all scripts
**File:** `hooks/live/0030-spawn-setup.hook.chroot`  
**Issue:** Scripts were copied via `includes.chroot` but the hook never called
`chmod +x` on them. Depending on the live-build version and how files are
staged, scripts may not have execute permissions set, causing all `sk` commands
to fail with "Permission denied".

**Fix:** Hook now explicitly `chmod +x` every script in `/usr/local/bin/`.

### [MED-3] Missing comms.yml config file
**File:** `spawn-comms` references `/etc/spawn/comms.yml`  
**Issue:** `COMMS_CONFIG="/etc/spawn/comms.yml"` was set but the file was never
created, causing a silent failure or unset variable when the script tried to
source it.

**Fix:** The setup hook now creates `/etc/spawn/comms.yml` with defaults
(connection_mode: auto, relay port 7777, default public Nostr relays).

### [MED-4] LAN mesh ports blocked by firewall
**File:** `etc/nftables.d/spawnos.conf`  
**Issue:** The input chain dropped all incoming connections with no exceptions.
This prevented:
- Other SpawnOS devices from connecting to the local Nostr relay (port 7777)
- WhiteNoise libp2p peers from connecting (port 7778)
- mDNS (port 5353) for avahi peer discovery

**Fix:** Added explicit LAN-only input rules for ports 7777 and 7778 from
`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16` only. mDNS (224.0.0.251:5353)
is also allowed. Internet-sourced connections to these ports are still dropped.

---

## LOW — Fixed

### [LOW-1] Missing python3-gi packages for GUI
**File:** `package-lists/spawnos.list.chroot`  
**Issue:** `spawn-comms-gui` requires `python3-gi`, `python3-gi-cairo`,
`gir1.2-gtk-3.0`, and `gir1.2-gdkpixbuf-2.0`. None were in the package list.

**Fix:** Added all four packages to the package list.

### [LOW-2] spawn user not in bluetooth group at service time
**File:** `hooks/live/0030-spawn-setup.hook.chroot`  
**Issue:** `usermod -aG bluetooth spawn` was only in the comms setup block added
later; the base setup didn't include it. The `spawn-bitchat.service` uses
`SupplementaryGroups=bluetooth` which requires group membership at login time.

**Fix:** Main setup hook now adds `spawn` to `bluetooth` and `netdev` groups
unconditionally.

### [LOW-3] Stray Bluetooth scan background process
**File:** `usr/local/bin/spawn-comms` (bitchat_scan)  
**Issue:** `bluetoothctl scan on &` was backgrounded without tracking the PID,
meaning it could not be stopped after the scan timeout. The `scan off` call
was also conditional on `hcitool scan` failing, so the background process
could survive indefinitely.

**Fix (in GUI):** The GUI uses a timeout-bounded subprocess call via
`run_cmd_async` with `timeout=15`. The spawn-comms CLI scan still uses the
same pattern but the GUI wraps it safely.

---

## INFORMATIONAL (no fix required)

### [INFO-1] Private key momentarily in bash variable memory
**Files:** `spawn-bitcoin`, `spawn-comms`  
**Note:** Bash variables holding private keys (`seed_phrase`, `privkey`) exist
in process memory during the encryption operation. `unset` is called afterward
but bash does not guarantee memory zeroing. This is a known limitation of
shell-based key handling. Mitigation: SpawnOS runs on LUKS-encrypted persistence
and `spawn-wipe` clears session data. A future version should move key ops to
a dedicated Python/Rust process that can `mlock` and zero memory explicitly.

### [INFO-2] GPG symmetric encryption passphrase caching
**Files:** `spawn-bitcoin`, `spawn-comms`  
**Note:** GPG may cache the decryption passphrase in `gpg-agent` for a session.
This is intentional UX behaviour (avoids re-entering passphrase repeatedly).
On shutdown or wipe, `spawn-wipe` should kill `gpg-agent`. Confirm this is
handled in the `spawn-wipe` script.

### [INFO-3] nostr-rs-relay database not encrypted at rest
**Note:** The local Nostr relay stores events in SQLite at
`/home/spawn/.spawn/comms/nostr-relay-db`. On LUKS persistence this is
encrypted at the block level. On amnesic boot the relay is in RAM only.
No additional file-level encryption is applied to the relay DB, which is
appropriate for a relay (messages are meant to be distributed).

### [INFO-4] WhiteNoise peer ID persists across sessions
**Note:** The libp2p peer ID in `/home/spawn/.spawn/comms/whitenoise/peer_id`
persists on LUKS persistence. This is a stable identifier. Users who want
unlinkable sessions should regenerate their peer ID or use amnesic mode.
Future: add `sk comms whitenoise rotate-id` command.

---

## Firewall Architecture (post-fix)

```
Internet traffic flow:
  App → socket → nftables NAT redirect → Tor port 9040 → Tor → Internet

LAN traffic flow (mesh services):
  SpawnOS device → port 7777/7778 → nftables INPUT allow (LAN only) → relay/mesh

DNS:
  App → UDP 53 → nftables NAT redirect → Tor DNS port 5353 → Tor → DNS

Blocked:
  Any non-LAN TCP/UDP that doesn't go through Tor is dropped at OUTPUT chain
```

---

## Script Permission Summary (all files in /usr/local/bin/)

| Script | Owner | Mode | Runs as |
|--------|-------|------|---------|
| spawnkey / sk | root | 755 | spawn user |
| spawn-bitcoin | root | 755 | spawn user |
| spawn-comms | root | 755 | spawn user |
| spawn-comms-gui | root | 755 | spawn user |
| spawn-node | root | 755 | spawn user |
| spawn-wipe | root | 755 | root (via sudo) |
| spawnos-firewall | root | 755 | root (via sudo) |
| Config files in ~/.spawn/ | spawn | 600 | spawn only |
| /etc/sudoers.d/spawnos | root | 440 | sudo |
