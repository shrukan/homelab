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

2. **Configure:** create `.env.local` from `.env.example`. Only the
   *Required* block has to be filled in: `PUID`, `PGID` and the three root
   directories. Everything else has a default, shown commented out; uncomment
   a line only to change it. A missing required value stops `docker compose`
   with a message naming it, instead of mounting an empty path.

3. **Initialize each service once:** `task service:init SERVICE="SERVICE_NAME"`.
   It creates the directories and makes sure they belong to `PUID:PGID`,
   asking for `sudo` only when the ownership is actually wrong. Run it again
   only after moving or restoring a service's directories; `service:start`
   does not repeat it, since checking a large tree like Plex's metadata on
   every start is slow.

4. **Start:** `task service:start SERVICE="SERVICE_NAME"`.

Without Task, export the variables first (`set -a; source .env.local; set +a`),
then run `./init.sh` once and `docker compose up -d` in the service's
directory under `services/`.

## Backups

The rule is simple: back up only what would have to be put back by hand.

That means the files collected manually, the `Books`, `Audiobooks` and `Comics`
libraries, and the state each application built up over time under
`APPDATA_ROOT`: its settings, indexers, quality profiles, watch history and
requests. The `.env.local` file is included too, since it is gitignored and
therefore usually exists nowhere else.

Everything a service fetches or generates by itself is left out, however long
it takes to come back. Films and TV shows can be downloaded again, and artwork,
thumbnails, transcoder scratch and logs are all rebuilt on demand.

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
