#!/usr/bin/env bash
set -euo pipefail

echo "Initializing ARR stack directories..."

# Media directories (read-only library)
mkdir -p \
	"${MEDIA_ROOT}/Movies" \
	"${MEDIA_ROOT}/Movies (4K)" \
	"${MEDIA_ROOT}/Animes" \
	"${MEDIA_ROOT}/Family Videos" \
	"${MEDIA_ROOT}/TV Shows"

mkdir -p "${DOWNLOAD_ROOT}"

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
