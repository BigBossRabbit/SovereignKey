#!/bin/bash
# =============================================================================
#  SpawnOS USB Installer — scripts/install-sk.sh
# =============================================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

[ $# -lt 1 ] && {
  echo "Usage: $0 <device> [iso-path]"
  echo "Example: $0 /dev/sdb"
  exit 1
}

DEVICE="$1"
ISO="${2:-dist/spawnos-1.0.0-amd64.iso}"

[ ! -b "$DEVICE" ] && { echo -e "${RED}Not a block device: $DEVICE${NC}"; exit 1; }
[ ! -f "$ISO" ]    && { echo -e "${RED}ISO not found: $ISO — run scripts/build-iso.sh first${NC}"; exit 1; }

echo -e "${YELLOW}=== SpawnOS USB Installer ===${NC}"
lsblk "$DEVICE"
echo ""
echo -e "${RED}WARNING: ALL DATA ON $DEVICE WILL BE ERASED${NC}"
read -p "Type 'yes' to confirm: " confirm
[ "$confirm" != "yes" ] && { echo "Cancelled."; exit 0; }

umount "${DEVICE}"* 2>/dev/null || true
sudo dd if="$ISO" of="$DEVICE" bs=4M status=progress conv=fsync
sync
echo -e "${GREEN}✓ SpawnOS written to $DEVICE${NC}"
