#!/usr/bin/env bash
set -euo pipefail

# Load environment variables
source ../../.env.local

echo "Initializing Audiobookshelf directories..."

# Media directories (read-only library)
mkdir -p \
	"${MEDIA_ROOT}/Books" \
	"${MEDIA_ROOT}/Audiobooks" \
	"${MEDIA_ROOT}/Comics"

# App data directories (writable state)
mkdir -p \
	"${APPDATA_ROOT}/audiobookshelf/config" \
	"${APPDATA_ROOT}/audiobookshelf/metadata"

# Apply ownership (important for Docker permissions)
chown -R "${UID}:${GID}" "${APPDATA_ROOT}/audiobookshelf"

echo "Done."
