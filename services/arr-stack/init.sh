#!/usr/bin/env bash
set -euo pipefail

echo "Initializing ARR stack directories..."

# Media directories (read-only library)
mkdir -p \
	"${MEDIA_ROOT}/Library/Movies" \
	"${MEDIA_ROOT}/Library/Movies (4K)" \
	"${MEDIA_ROOT}/Library/Animes" \
	"${MEDIA_ROOT}/Library/Family Videos" \
	"${MEDIA_ROOT}/Library/TV Shows"

mkdir -p "${MEDIA_ROOT}/complete"

# App data directories (writable state)
mkdir -p \
	"${APPDATA_ROOT}/arr_stack" \
	"${APPDATA_ROOT}/arr_stack/sonarr/config" \
	"${APPDATA_ROOT}/arr_stack/radarr/config" \
	"${APPDATA_ROOT}/arr_stack/radarr4k/config" \
	"${APPDATA_ROOT}/arr_stack/prowlarr/config" \
	"${APPDATA_ROOT}/arr_stack/seerr/config" \
	"${APPDATA_ROOT}/arr_stack/tautulli/config" \
	"${APPDATA_ROOT}/arr_stack/requestrr/config" \
	"${APPDATA_ROOT}/arr_stack/profilarr/config"

# Apply ownership (important for Docker permissions)
chown -R "${UID}:${GID}" "${APPDATA_ROOT}/arr_stack"

echo "Done."
