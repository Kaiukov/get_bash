# Project Context: get_bash

## Overview
This project contains bash scripts and configuration files for setting up development environments with Docker, Docker Compose, and Tailscale. It's designed to streamline the installation and configuration process for containerized applications running on Tailscale networks.

## Directory Structure
```
get_bash/
├── bash/
│   └── install_docker_tailscale.sh      # Script to install Docker, Docker Compose, and Tailscale
├── compose.yml                          # Docker Compose configuration for Tailscale + Nginx setup
├── .env                                 # Environment variables for Docker Compose
├── serve.json                           # Tailscale serve configuration
├── nginx.conf                           # Nginx configuration to serve bash scripts
└── QWEN.md                              # Current file with project context
```

## Key Files and Their Purpose

### `bash/install_docker_tailscale.sh`
A bash script that automates the installation of:
- Docker and Docker Compose
- Tailscale
- Prerequisites and package updates
The script includes validation to ensure successful installation of each component and adds the current user to the docker group for non-root Docker usage.

### `compose.yml`
A Docker Compose configuration file that sets up:
- A Tailscale container that connects to your Tailscale network
- An Nginx service that runs on the Tailscale network and serves bash scripts from the bash directory
The configuration uses environment variables from the `.env` file for authentication and hostname settings.

### `.env`
Environment file containing:
- `TS_AUTHKEY`: Your Tailscale authentication key
- `HOSTNAME`: The hostname for the Tailscale service

### `serve.json`
Tailscale serve configuration that sets up HTTPS serving on port 443 and proxies requests to the nginx container.

### `nginx.conf`
Nginx configuration that serves bash scripts from the mounted bash directory and sets proper content-type for .sh files.

## Project Type
This is a DevOps/Infrastructure project focused on containerization and secure networking. It provides tools to set up Docker and Tailscale environments for applications that need to run on secure, private networks.

## Usage
1. **Install dependencies**: Run the bash script `bash/install_docker_tailscale.sh` to install Docker, Docker Compose, and Tailscale.
2. **Configure environment**: Update the `.env` file with your specific Tailscale authentication key and hostname.
3. **Deploy services**: Use Docker Compose to run the configured services with `docker compose up`.
4. **Download scripts remotely**: The bash scripts can also be downloaded directly from the Tailscale network using the URL http://get.neon-chuckwalla.ts.net/install_docker_tailscale.sh
5. **Execute remotely**: To run the installation script directly from the Tailscale network:
   ```bash
   curl -fsSL http://get.neon-chuckwalla.ts.net/install_docker_tailscale.sh | sh
   ```
   Or using bash:
   ```bash
   curl -fsSL http://get.neon-chuckwalla.ts.net/install_docker_tailscale.sh | bash
   ```

## Development Conventions
- This project uses bash scripting for automation
- Uses Docker Compose for container orchestration
- Follows security best practices by using environment variables for sensitive information
- Uses Tailscale for secure, private networking between containers and other devices

## Important Notes
- The bash script should be run as a regular user with sudo privileges (not as root)
- After running the installation script, you need to log out and log back in to apply docker group membership changes
- Tailscale ephemeral nodes are disabled by default in the compose file
- The Nginx service is configured to run on the same network as the Tailscale container