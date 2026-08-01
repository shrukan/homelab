#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../../scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"

echo "Initializing Audiobookshelf directories..."

# Media directories (read-only library)
mkdir -p \
	"${MEDIA_ROOT}/Library/Books" \
	"${MEDIA_ROOT}/Library/Audiobooks" \
	"${MEDIA_ROOT}/Library/Comics"

# App data directories (writable state)
mkdir -p \
	"${APPDATA_ROOT}/audiobookshelf/config" \
	"${APPDATA_ROOT}/audiobookshelf/metadata"

# Apply ownership (important for Docker permissions), escalating only if needed
ensure_owner "${APPDATA_ROOT}/audiobookshelf"

echo "Done."
