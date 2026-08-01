#!/usr/bin/env bash
set -euo pipefail

# Backs up the data that cannot be re-downloaded: service configuration
# (databases, settings, watch history) and the book/audiobook libraries.
# Films and TV are deliberately excluded, they are replaceable.
#
# Containers are stopped for the duration of the snapshot. The arr apps,
# Plex and Tautulli all keep their state in SQLite, and copying those files
# while they are being written can produce a snapshot that restores corrupt.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXCLUDE_FILE="${REPO_ROOT}/scripts/backup-excludes.txt"
TAG=homelab

KEEP_DAILY="${BACKUP_KEEP_DAILY:-7}"
KEEP_WEEKLY="${BACKUP_KEEP_WEEKLY:-4}"
KEEP_MONTHLY="${BACKUP_KEEP_MONTHLY:-6}"

usage() {
	cat <<-EOF
		Usage: ${0##*/} [command]

		Commands:
		  backup     Stop services, snapshot, restart, prune old snapshots (default)
		  init       Create the restic repository (run once)
		  check      Verify repository integrity
		  snapshots  List existing snapshots
		  restore    Restore a snapshot: restore <snapshot-id> <target-dir>
	EOF
}

require_env() {
	: "${RESTIC_REPOSITORY:?not set, see .env.example}"
	if [ -z "${RESTIC_PASSWORD:-}" ] && [ -z "${RESTIC_PASSWORD_FILE:-}" ]; then
		echo "Error: set RESTIC_PASSWORD_FILE (or RESTIC_PASSWORD), see .env.example" >&2
		exit 1
	fi
	command -v restic >/dev/null || {
		echo "Error: restic is not installed" >&2
		exit 1
	}
}

# Every directory under services/ that holds a compose file. Passing
# --project-directory keeps the compose project name identical to the one
# Task creates, so we stop and start the containers Task started.
service_dirs() {
	find "${REPO_ROOT}/services" -mindepth 2 -maxdepth 2 -name compose.yml -printf '%h\n' | sort
}

compose() {
	local dir="$1"
	shift
	docker compose --project-directory "${dir}" -f "${dir}/compose.yml" "$@"
}

STOPPED=()

# Runs on any exit, including failure, so a broken backup never leaves the
# lab switched off.
restart_services() {
	local dir
	for dir in ${STOPPED[@]+"${STOPPED[@]}"}; do
		echo "Starting ${dir##*/}..."
		compose "${dir}" start >/dev/null || echo "WARNING: could not restart ${dir##*/}" >&2
	done
}

collect_paths() {
	local paths=("${APPDATA_ROOT:?not set}")
	local lib

	# Holds every API key and the Plex claim token, and is gitignored, so
	# this is usually the only copy in existence.
	[ -f "${REPO_ROOT}/.env.local" ] && paths+=("${REPO_ROOT}/.env.local")

	for lib in Books Audiobooks Comics; do
		[ -d "${MEDIA_ROOT:?not set}/Library/${lib}" ] && paths+=("${MEDIA_ROOT}/Library/${lib}")
	done

	printf '%s\n' "${paths[@]}"
}

do_backup() {
	local dir
	mapfile -t paths < <(collect_paths)

	trap restart_services EXIT
	for dir in $(service_dirs); do
		echo "Stopping ${dir##*/}..."
		compose "${dir}" stop >/dev/null
		STOPPED+=("${dir}")
	done

	echo "Backing up..."
	restic backup --tag "${TAG}" --exclude-file "${EXCLUDE_FILE}" "${paths[@]}"

	# Containers are back up before pruning, which needs no consistency.
	restart_services
	STOPPED=()
	trap - EXIT

	echo "Pruning old snapshots..."
	restic forget --tag "${TAG}" \
		--keep-daily "${KEEP_DAILY}" \
		--keep-weekly "${KEEP_WEEKLY}" \
		--keep-monthly "${KEEP_MONTHLY}" \
		--prune

	echo "Done."
}

main() {
	local cmd="${1:-backup}"
	case "${cmd}" in
		backup)
			require_env
			do_backup
			;;
		init)
			require_env
			restic init
			;;
		check)
			require_env
			restic check --read-data-subset=5%
			;;
		snapshots)
			require_env
			restic snapshots --tag "${TAG}"
			;;
		restore)
			require_env
			[ $# -eq 3 ] || {
				echo "Usage: ${0##*/} restore <snapshot-id> <target-dir>" >&2
				exit 1
			}
			restic restore "$2" --target "$3"
			;;
		-h | --help | help)
			usage
			;;
		*)
			usage >&2
			exit 1
			;;
	esac
}

main "$@"
