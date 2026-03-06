#!/bin/bash
# =============================================================================
#  sync-spawn.sh — Sync Spawn agent code into the SpawnOS build tree
#  Reads from your Spawn project. Never writes back to it.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SPAWN_SOURCE="${SPAWN_SOURCE:-$HOME/Documents/Spawn/spawn}"
SPAWN_DEST="$PROJECT_ROOT/live-build/config/includes.chroot/usr/local/share/spawnos/agent"

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

[ ! -d "$SPAWN_SOURCE" ] && {
  echo -e "${RED}Spawn source not found: $SPAWN_SOURCE${NC}"
  echo "Set SPAWN_SOURCE env var or ensure Spawn is at ~/Documents/Spawn/spawn"
  exit 1
}

echo -e "${GREEN}Syncing Spawn agent:${NC}"
echo "  from: $SPAWN_SOURCE"
echo "  to:   $SPAWN_DEST"

mkdir -p "$SPAWN_DEST"
rsync -av --delete \
  --exclude='.git' \
  --exclude='__pycache__' \
  --exclude='*.pyc' \
  --exclude='.env' \
  --exclude='node_modules' \
  --exclude='.DS_Store' \
  --exclude='*.log' \
  "$SPAWN_SOURCE/" "$SPAWN_DEST/"

echo -e "${GREEN}✓ Spawn agent synced${NC}"
echo "Next: sudo scripts/build-iso.sh"
