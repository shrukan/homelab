# homelab

This repository contains the configuration files and scripts for my homelab setup,
consisting of various containers.

## Contents

* `services/`: All service related files such as compose and initialization script.
* `scripts/`: Maintenance scripts and the systemd units that schedule them.

## Services

Following services are available

* Audiobookshelf: (Audio-)book and comic management.
* Sabnzbd: NZB downloader.
* Arr-Stack: Multiple Arr apps for tv-show and movie management.
* Plex: Tool for watching movies and TV shows.

## Getting Started

This repository uses Task as a command runner. It is possible to deploy and execute all the scripts without using
Task, but since a lot of the files are using environment variables it is necessary to export the `.env.local` file beforehand.

1. **Clone the Repository:**

    ```bash
    git clone https://github.com/shrukan/homelab.git
    cd homelab 
    ```

2. **Deploy Services:**
   * Create a `.env.local` file from the `.env.example`, filling in your specific details.
   * Export the variables: `set -a; source .env.local; set +a`.
   * Navigate to each service directory in `services/`.
   * Execute the `init.sh` script.
   * Start the service: `docker compose up -d`.
   * Alternatively, initialize and start each service with Task: `task service:start SERVICE="SERVICE_NAME"`.

## Backups

Backups cover the data that cannot simply be downloaded again: the service
configuration under `APPDATA_ROOT` (databases, settings, watch history), the
`.env.local` file, and the `Books`, `Audiobooks` and `Comics` libraries. Films
and TV shows are excluded, as are transcoder scratch space, logs and the
artwork caches that each service regenerates on its own.

[restic](https://restic.net/) does the work, so snapshots are encrypted and
deduplicated. The destination is just the `RESTIC_REPOSITORY` URL, which can be
a local disk, SFTP, object storage or an rclone remote.

The arr apps, Plex and Tautulli all keep their state in SQLite. Copying those
files while they are being written can produce a snapshot that restores
corrupt, so the backup stops every container, takes the snapshot, and starts
them again. Expect a couple of minutes of downtime. Containers are restarted
even if the backup fails.

1. **Set up:**
   * Install restic.
   * Write a strong password to a file outside the repository and `chmod 600`
     it. Losing that file means losing the backup, it cannot be recovered.
   * Set `RESTIC_REPOSITORY` and `RESTIC_PASSWORD_FILE` in `.env.local`.
   * Create the repository once: `task backup:init`.

2. **Run it:**

   ```bash
   task backup             # stop, snapshot, restart, prune
   task backup:snapshots   # list what exists
   task backup:check       # verify repository integrity
   ```

3. **Schedule it:** copy `scripts/systemd/homelab-backup.{service,timer}` to
   `/etc/systemd/system/`, correct the paths inside the unit to match where
   this repository is checked out, then
   `sudo systemctl enable --now homelab-backup.timer`. It runs nightly at
   04:00.

Restore a snapshot into a scratch directory with
`task backup:restore -- latest /tmp/restore`. Do this once before you need it,
an untested backup is only a hypothesis.
