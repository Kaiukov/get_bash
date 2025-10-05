# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
DevOps/Infrastructure project providing bash scripts and Docker Compose configurations for automated installation of Docker, Docker Compose, and Tailscale, plus containerized Nginx serving bash scripts over a Tailscale network.

## Key Architecture

### Service Architecture
The project uses a **shared network pattern** where:
- Tailscale container provides network layer with `network_mode: service:tailscale-nginx`
- Nginx container shares Tailscale's network namespace
- Traffic flow: Tailscale HTTPS (443) → Nginx (80) → bash scripts
- Tailscale serve configuration (`serve.json`) proxies HTTPS to local Nginx

### Critical Dependencies
- Tailscale container **must** start before Nginx (enforced via `depends_on`)
- Environment variables (`TS_AUTHKEY`, `HOSTNAME`) required for Tailscale authentication
- `/dev/net/tun` device and `net_admin` capability required for Tailscale networking

## Common Commands

### Testing Scripts Locally
```bash
# Test installation script locally (requires sudo)
bash bash/install_docker_tailscale.sh

# Test Unicode fix script
bash bash/fix-unicode-bash.sh
```

### Docker Compose Operations
```bash
# Start services (requires .env file with TS_AUTHKEY and HOSTNAME)
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down

# Rebuild after changes
docker compose up -d --build
```

### Remote Script Execution
Scripts are served via Tailscale network:
```bash
# Download script
curl -fsSL http://get.neon-chuckwalla.ts.net/install_docker_tailscale.sh

# Execute directly
curl -fsSL http://get.neon-chuckwalla.ts.net/install_docker_tailscale.sh | sh
```

## Development Constraints

### Script Requirements
- **install_docker_tailscale.sh**: Must run as non-root user with sudo privileges (exits if run as root)
- All scripts use `set -e` for fail-fast behavior
- Scripts validate installation success before completing

### Environment File
`.env` file required with:
```
TS_AUTHKEY=your-tailscale-auth-key
HOSTNAME=your-tailscale-hostname
```
This file should **never** be committed (already in .gitignore)

### Tailscale Configuration
- `ephemeral=false` in auth key means nodes persist in Tailscale network
- `--advertise-tags=tag:container` requires ACL configuration in Tailscale admin
- `serve.json` uses `${TS_CERT_DOMAIN}` variable substitution (not standard JSON)

## Important Notes
- User must log out/in after running installation script for docker group membership
- Nginx serves from `/usr/share/nginx/html` (mounted from `./bash` directory)
- `.sh` files served with `Content-Type: application/x-sh` header
- Tailscale state persisted in `./tailscale-nginx/state/` directory
