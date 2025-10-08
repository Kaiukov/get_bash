# Installation Scripts

Quick setup scripts for Ubuntu environments.

## Infrastructure Tools (Docker + Tailscale)

Install Docker, Docker Compose, and Tailscale:
```bash
curl -fsSL https://raw.githubusercontent.com/Kaiukov/get_bash/main/bash/install_infrastructure.sh | bash
```

**Includes:**
- Docker CE with BuildKit and Compose plugin
- Tailscale VPN client
- Apt lock handling for reliable installation
- Automatic user group configuration

## Development Tools (Node.js + AI Code Assistants)

Install Node.js 22, Claude Code, and Qwen Code:
```bash
curl -fsSL https://raw.githubusercontent.com/Kaiukov/get_bash/main/bash/install_dev_tools.sh | bash
```

**Includes:**
- NVM (Node Version Manager)
- Node.js 22 LTS
- Claude Code CLI
- Qwen Code CLI

## System Fixes

Fix Unicode/UTF-8 display issues:
```bash
curl -fsSL https://raw.githubusercontent.com/Kaiukov/get_bash/main/bash/fix-unicode-bash.sh | bash
```

## Notes

- Scripts can be run independently in any order
- Infrastructure script requires sudo access
- Development tools script runs without sudo
- Both scripts include validation and error handling