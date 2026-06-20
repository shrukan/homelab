#!/usr/bin/env bash
set -euo pipefail

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

# Apply ownership (important for Docker permissions)
chown -R "${UID}:${GID}" "${APPDATA_ROOT}/audiobookshelf"

echo "Done."
