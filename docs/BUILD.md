# Building SpawnOS

## Requirements

- Debian 12 or Ubuntu 22.04+ host
- Root access
- ~20GB free disk
- Internet connection (packages downloaded at build time)

## Install Build Dependencies

```bash
sudo apt-get install -y live-build debootstrap squashfs-tools xorriso syslinux isolinux
```

## Build Steps

```bash
# 1. Sync your Spawn agent
scripts/sync-spawn.sh

# 2. Build ISO (requires sudo, 20-60 min)
sudo scripts/build-iso.sh

# 3. Flash to USB (replace /dev/sdX)
scripts/install-sk.sh /dev/sdX
```

## Customise Before Building

- Add packages: `live-build/config/package-lists/spawnos.list.chroot`
- Change Tor config: `live-build/config/includes.chroot/etc/tor/torrc`
- Change firewall: `live-build/config/includes.chroot/etc/nftables.d/spawnos.conf`
- Spawn config: `live-build/config/includes.chroot/etc/spawn/config.yml`
