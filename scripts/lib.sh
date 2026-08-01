#!/usr/bin/env bash
# Shared helpers for the service initialization scripts.

# Makes sure the given paths belong to PUID:PGID, which is what the containers
# run as. Docker creates a missing bind mount source as root:root, so without
# this a container running as a normal user cannot write to its own config.
#
# chown needs root, but only when something is actually wrong. Checking first
# means a re-run against an already correct tree needs no privileges, and the
# usual `task service:start` never asks for a password.
ensure_owner() {
	: "${PUID:?not set, see .env.example}"
	: "${PGID:?not set, see .env.example}"

	local path mismatch
	for path in "$@"; do
		[ -e "${path}" ] || continue

		# -quit stops at the first offender, so this stays cheap on a large tree.
		# If find itself fails, for instance because part of the tree cannot be
		# read, fall through and fix the ownership rather than silently skipping.
		if mismatch="$(find "${path}" \( ! -uid "${PUID}" -o ! -gid "${PGID}" \) -print -quit 2>/dev/null)"; then
			[ -n "${mismatch}" ] || continue
		fi

		if [ "$(id -u)" -eq 0 ]; then
			chown -R "${PUID}:${PGID}" "${path}"
		elif command -v sudo >/dev/null 2>&1; then
			echo "Setting ownership of ${path} to ${PUID}:${PGID}, this needs root."
			sudo chown -R "${PUID}:${PGID}" "${path}"
		else
			echo "Error: ${path} is not owned by ${PUID}:${PGID}, and neither root nor sudo is available." >&2
			echo "Fix it with: chown -R ${PUID}:${PGID} ${path}" >&2
			return 1
		fi
	done
}
