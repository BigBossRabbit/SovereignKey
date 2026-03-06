# Building SpawnOS ISO on Kali Linux

## Overview

Your Kali Linux machine will act as the build host. It runs `live-build` which
downloads Debian packages and assembles a bootable SpawnOS ISO from scratch.
The ISO goes onto your USB. The Kali machine itself is not modified — it's just
the factory.

Estimated time: 30-90 minutes depending on internet speed and hardware.
Disk space needed: ~20GB free on the Kali machine.

---

## Step 1 — Get the SovereignKey repo onto your Kali machine

Open a terminal on your Kali machine and run:

```bash
git clone https://github.com/BigBossRabbit/SovereignKey.git
cd SovereignKey
```

If you've already pushed from your Mac, this pulls the latest SpawnOS build system.

---

## Step 2 — Install build dependencies

Kali is Debian-based so this works cleanly:

```bash
sudo apt-get update
sudo apt-get install -y \
  live-build \
  debootstrap \
  squashfs-tools \
  xorriso \
  syslinux \
  syslinux-common \
  isolinux \
  grub-pc-bin \
  grub-efi-amd64-bin \
  mtools \
  rsync
```

Verify live-build is installed:
```bash
lb --version
# Should print something like: live-build 20230502
```

---

## Step 3 — Sync your Spawn agent into the build (optional but recommended)

If you have Spawn on this machine or can transfer it:

```bash
# If Spawn is on this Kali machine:
SPAWN_SOURCE=/path/to/spawn scripts/sync-spawn.sh

# If you need to copy it from another machine first:
scp -r user@yourmac:~/Documents/Spawn/spawn /tmp/spawn
SPAWN_SOURCE=/tmp/spawn scripts/sync-spawn.sh
```

If you skip this, SpawnOS will boot in stub mode — everything works except
the Spawn agent, which you can install later into the persistence volume.

---

## Step 4 — Build the ISO

```bash
sudo scripts/build-iso.sh
```

This will:
1. Configure live-build for Debian Bookworm (Debian 12)
2. Run `lb build` which debootstraps Debian, installs all packages,
   runs the three hooks (privacy hardening, Bitcoin tools, Spawn setup),
   copies all config files into the chroot, and assembles the ISO
3. Output the ISO to `dist/spawnos-1.0.0-amd64.iso`

You'll see a lot of output scrolling past — this is normal.
A `build.log` file captures everything if something goes wrong.

**If the build fails:** check `build.log` and look for the first ERROR line.
Most common issues are network timeouts (re-run, it retries) or a missing
package name (edit the package list and re-run).

To restart a failed build cleanly:
```bash
cd live-build && sudo lb clean --all && cd ..
sudo scripts/build-iso.sh
```

---

## Step 5 — Verify the ISO

```bash
ls -lh dist/spawnos-1.0.0-amd64.iso
```

Expected size: **1.5 GB to 3 GB** depending on how many Bitcoin tools
downloaded successfully during the build.

Run a quick integrity check:
```bash
sha256sum dist/spawnos-1.0.0-amd64.iso | tee dist/spawnos-1.0.0-amd64.iso.sha256
```

Save that SHA256 — you can verify the USB write later.

---

## Step 6 — Identify your USB drive

**CRITICAL: Get this wrong and you wipe the wrong disk.**

With USB inserted:
```bash
lsblk
```

Look for a device the size of your USB (e.g. 8GB, 16GB, 32GB).
It will be something like `/dev/sdb` or `/dev/sdc`.

**Do NOT use `/dev/sda`** — that is almost certainly your Kali machine's
internal hard drive.

Example output — your USB will look like this:
```
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda    ...          500G  0 disk           ← your Kali hard drive, SKIP
sdb    ...           32G  0 disk           ← your USB drive, USE THIS
```

---

## Step 7 — Flash the ISO to USB

Replace `/dev/sdb` with your actual USB device:

```bash
sudo scripts/install-sk.sh /dev/sdb
```

Or manually with dd:
```bash
sudo dd if=dist/spawnos-1.0.0-amd64.iso of=/dev/sdb bs=4M status=progress conv=fsync
sync
```

The flash takes 3-10 minutes for a ~2GB ISO.

---

## Step 8 — Verify the write (optional but good practice)

```bash
# Read back from USB and hash it, compare to ISO hash
sudo dd if=/dev/sdb bs=4M count=$(( $(stat -c%s dist/spawnos-1.0.0-amd64.iso) / (4*1024*1024) + 1 )) 2>/dev/null | \
  sha256sum
# Compare first 64 chars to the hash from Step 5
```

---

## Step 9 — Boot SpawnOS

1. Remove USB from Kali machine
2. Insert into target machine
3. Power on, press boot menu key (see README for your hardware)
4. Select USB boot
5. GRUB menu appears — select **SpawnOS**
6. On first boot with no persistence: boots straight to desktop
7. On subsequent boots with persistence: enter your LUKS passphrase

### First boot setup:
```bash
spawnkey init    # or: sk init
spawnkey status  # verify everything is running
```

---

## Troubleshooting

**USB not booting:**
- Try "SpawnOS (Failsafe)" from the GRUB menu
- Check BIOS: Secure Boot should be OFF, Legacy/UEFI boot order should have USB first
- Re-flash the USB (the write may have failed)

**Build fails at Bitcoin tools hook:**
- Network timeouts are common — just re-run `sudo scripts/build-iso.sh`
- The hooks have retry logic but some downloads are slow
- You can comment out specific tool downloads in
  `live-build/config/hooks/live/0020-bitcoin-tools.hook.chroot` and install
  them manually after first boot

**Spawn agent not starting:**
- Expected on first boot if you skipped Step 3
- Run `sk init` after booting to configure
- Copy Spawn into persistence: see `docs/SPAWN_INTEGRATION.md`

**"lb: command not found":**
- `live-build` didn't install correctly
- Try: `sudo apt-get install --fix-broken && sudo apt-get install live-build`
