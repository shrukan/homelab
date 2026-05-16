#!/usr/bin/env bash
set -euo pipefail

echo "Initializing Sabnzbd directories..."

# Media directories (read-only library)
mkdir -p \
	"${DOWNLOAD_ROOT}" \
	"${INCOMPLETE_DOWNLOAD_ROOT}"

# App data directories (writable state)
mkdir -p \
	"${APPDATA_ROOT}/sabnzbd/config"

# Apply ownership (important for Docker permissions)
chown -R "${UID}:${GID}" "${APPDATA_ROOT}/sabnzbd"

echo "Done."
