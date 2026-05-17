# homelab

This repository contains the configuration files and scripts for my homelab setup,
consisting of various containers.

## Contents

* `services/`: All service related files such as compose and initialization script.

## Services

Following services are available

* Audiobookshelf: (Audio-)book and comics management.
* Sabnzbd: NZB downloader.
* Plex: Tool for watching movies and TV shows.

## Getting Started

This repository uses Task as a command runner. It is possible to deploy and execute all the scripts without using
Task, but since a lot of the files are using environment variables it is necessary to source the `env.local` file beforehand.

1. **Clone the Repository:**

    ```bash
    git clone https://github.com/shrukan/homelab.git
    cd homelab 
    ```

2. **Deploy Services:**
   * Create a `.env.local` file from the `.env.example`, filling in your specific details.
   * Source the file `source .env.local`.
   * Navigate to each service directory in `services/`.
   * Execute the `init.sh` script.
   * Start the service: `docker compose up -d`.
   * Alternatively, initialize and start each service with Task: `task service:start SERVICE="SERVICE_NAME"`.
