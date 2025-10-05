#!/bin/bash

# Script to install Docker, Docker Compose, and Tailscale on Ubuntu
# Author: Assistant
# Date: 2025-09-25

set -e  # Exit immediately if a command exits with a non-zero status

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate installed packages
validate_installation() {
    print_status "Validating installations..."

    # Check Docker
    if command -v docker &> /dev/null; then
        print_status "✓ Docker is installed. Version: $(docker --version)"
    else
        print_error "✗ Docker installation failed!"
        exit 1
    fi

    # Check Docker Compose
    if command -v docker-compose &> /dev/null; then
        print_status "✓ Docker Compose is installed. Version: $(docker-compose --version)"
    else
        print_error "✗ Docker Compose installation failed!"
        exit 1
    fi

    # Check Tailscale
    if command -v tailscale &> /dev/null; then
        print_status "✓ Tailscale is installed. Version: $(tailscale version | head -n 1)"
    else
        print_error "✗ Tailscale installation failed!"
        exit 1
    fi

    # Check Node.js
    if command -v node &> /dev/null; then
        print_status "✓ Node.js is installed. Version: $(node --version)"
    else
        print_error "✗ Node.js installation failed!"
        exit 1
    fi

    # Check npm
    if command -v npm &> /dev/null; then
        print_status "✓ npm is installed. Version: $(npm --version)"
    else
        print_error "✗ npm installation failed!"
        exit 1
    fi

    # Check Claude Code
    if command -v claude &> /dev/null; then
        print_status "✓ Claude Code is installed. Version: $(claude --version 2>&1 | head -n 1 || echo 'installed')"
    else
        print_error "✗ Claude Code installation failed!"
        exit 1
    fi

    # Check Qwen Code
    if command -v qwen &> /dev/null; then
        print_status "✓ Qwen Code is installed. Version: $(qwen --version 2>&1 | head -n 1 || echo 'installed')"
    else
        print_error "✗ Qwen Code installation failed!"
        exit 1
    fi
}

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    print_warning "Running as root. Docker group configuration will be skipped."
    print_warning "You will be able to run docker commands without sudo (already root)."
    RUNNING_AS_ROOT=true
else
    RUNNING_AS_ROOT=false
fi

print_status "Starting installation of Docker, Docker Compose, and Tailscale..."

# Update package index
print_status "Updating package index..."
sudo apt update

# Upgrade packages
print_status "Upgrading packages..."
sudo apt upgrade -y

# Install prerequisites
print_status "Installing prerequisites..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

# Install Docker
print_status "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add current user to docker group
if [ "$RUNNING_AS_ROOT" = false ]; then
    print_status "Adding current user to docker group..."
    sudo usermod -aG docker $USER
else
    print_status "Skipping docker group configuration (running as root)..."
fi

# Install Docker Compose
print_status "Installing Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -o '"tag_name":"[^"]*' | cut -d'"' -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Tailscale
print_status "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

# Install Node.js via NVM (Node Version Manager)
print_status "Installing NVM (Node Version Manager)..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# Load NVM into current shell
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Install Node.js 22 via NVM
print_status "Installing Node.js 22 via NVM..."
nvm install 22
nvm use 22

# Ensure node and npm are in PATH
export PATH="$NVM_DIR/versions/node/$(nvm version)/bin:$PATH"

# Verify Node.js and npm are available (test execution directly)
if ! node --version &> /dev/null || ! npm --version &> /dev/null; then
    print_error "Node.js or npm installation failed!"
    exit 1
fi

# Install Claude Code globally via npm
print_status "Installing Claude Code..."
npm install -g @anthropic-ai/claude-code

# Install Qwen Code globally via npm
print_status "Installing Qwen Code..."
npm install -g @qwen-code/qwen-code

# Validate installations
validate_installation

print_status "Installation completed successfully!"
print_warning "Please log out and log back in to apply the docker group membership changes."