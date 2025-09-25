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
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
    exit 1
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
print_status "Adding current user to docker group..."
sudo usermod -aG docker $USER

# Install Docker Compose
print_status "Installing Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -o '"tag_name":"[^"]*' | cut -d'"' -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Tailscale
print_status "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

# Validate installations
validate_installation

print_status "Installation completed successfully!"
print_warning "Please log out and log back in to apply the docker group membership changes."