#!/bin/bash
# =============================================================================
#  SpawnOS ISO Builder — scripts/build-iso.sh
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/live-build"
OUTPUT_DIR="$PROJECT_ROOT/dist"
SPAWNOS_VERSION="1.0.0"
DEBIAN_CODENAME="bookworm"

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${GREEN}[BUILD]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

[ "$EUID" -ne 0 ] && error "ISO build requires root: sudo $0"

check_deps() {
  info "Checking dependencies..."
  for dep in live-build debootstrap squashfs-tools xorriso; do
    command -v "$dep" &>/dev/null || error "Missing: $dep — install with: sudo apt-get install $dep"
  done
}

configure() {
  info "Configuring live-build for SpawnOS ${SPAWNOS_VERSION}..."
  cd "$BUILD_DIR"
  lb config \
    --architecture amd64 \
    --distribution "$DEBIAN_CODENAME" \
    --debian-installer false \
    --bootappend-live "boot=live components splash quiet apparmor=1 security=apparmor net.ifnames=0" \
    --bootloaders grub-pc \
    --iso-application "SpawnOS" \
    --iso-volume "SpawnOS ${SPAWNOS_VERSION}" \
    --iso-publisher "BigBossRabbit / SpawnOS" \
    --image-name "spawnos-${SPAWNOS_VERSION}-amd64" \
    --firmware-binary true \
    --firmware-chroot true \
    --security true \
    --updates true
}

build() {
  info "Building ISO (20-60 minutes)..."
  cd "$BUILD_DIR"
  lb build 2>&1 | tee "$PROJECT_ROOT/build.log"
  mkdir -p "$OUTPUT_DIR"
  mv "$BUILD_DIR"/*.iso "$OUTPUT_DIR/" 2>/dev/null || \
    error "ISO not found — check build.log"
  info "Done: $(ls -lh $OUTPUT_DIR/*.iso)"
}

case "${1:-build}" in
  configure) check_deps; configure ;;
  build)     check_deps; configure; build ;;
  clean)     cd "$BUILD_DIR" && lb clean --all ;;
  *) echo "Usage: $0 {build|configure|clean}" ;;
esac
