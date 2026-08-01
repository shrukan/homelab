#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../../scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"

echo "Initializing Plex directories..."

# Media directory (read-only library)
mkdir -p \
	"${MEDIA_ROOT}/Library"

# App data directories (writable state)
mkdir -p \
	"${APPDATA_ROOT}/plex/PlexMediaServer" \
	"${APPDATA_ROOT}/plex/transcode"

# Apply ownership (important for Docker permissions), escalating only if needed
ensure_owner "${APPDATA_ROOT}/plex"

echo "Done."
