#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../../scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"

echo "Initializing Sabnzbd directories..."

# Media directories (read-only library)
mkdir -p \
	"${MEDIA_ROOT}/complete" \
	"${INCOMPLETE_DOWNLOAD_ROOT}"

# App data directories (writable state)
mkdir -p \
	"${APPDATA_ROOT}/sabnzbd/config"

# Apply ownership (important for Docker permissions), escalating only if needed
ensure_owner "${APPDATA_ROOT}/sabnzbd"

echo "Done."
