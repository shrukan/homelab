#!/usr/bin/env bash
set -euo pipefail

echo "Initializing Plex directories..."

# Media directory (read-only library)
mkdir -p \
	"${MEDIA_ROOT}/Library"

# App data directories (writable state)
mkdir -p \
	"${APPDATA_ROOT}/plex/PlexMediaServer" \
	"${APPDATA_ROOT}/plex/transcode"

# Apply ownership (important for Docker permissions)
chown -R "${UID}:${GID}" "${APPDATA_ROOT}/plex"

echo "Done."
