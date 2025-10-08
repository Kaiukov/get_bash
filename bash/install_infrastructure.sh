#!/bin/bash

# Script to install Docker, Docker Compose, and Tailscale on Ubuntu
# Author: Assistant
# Date: 2025-10-08

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

# Function to wait for apt lock to be released
wait_for_apt_lock() {
    local max_wait=300  # 5 minutes max
    local wait_time=0
    local sleep_interval=5

    while fuser /var/lib/dpkg/lock >/dev/null 2>&1 || \
          fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || \
          fuser /var/lib/apt/lists/lock >/dev/null 2>&1 || \
          fuser /var/cache/apt/archives/lock >/dev/null 2>&1; do

        if [ $wait_time -ge $max_wait ]; then
            print_error "apt lock timeout after ${max_wait}s. Another package manager may be running."
            print_error "Please wait for other package operations to complete and try again."
            exit 1
        fi

        print_warning "Waiting for apt lock to be released... (${wait_time}s elapsed)"
        sleep $sleep_interval
        wait_time=$((wait_time + sleep_interval))
    done
}

# Validate installed packages
validate_installation() {
    print_status "Validating installations..."

    local all_valid=true

    # Check Docker
    if command -v docker &> /dev/null; then
        print_status "✓ Docker is installed. Version: $(docker --version)"
    else
        print_error "✗ Docker installation failed!"
        all_valid=false
    fi

    # Check Docker Compose
    if docker compose version &> /dev/null; then
        print_status "✓ Docker Compose is installed. Version: $(docker compose version)"
    else
        print_error "✗ Docker Compose installation failed!"
        all_valid=false
    fi

    # Check Tailscale
    if command -v tailscale &> /dev/null; then
        print_status "✓ Tailscale is installed. Version: $(tailscale version | head -n 1)"
    else
        print_error "✗ Tailscale installation failed!"
        all_valid=false
    fi

    if [ "$all_valid" = false ]; then
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

# Wait for any existing apt operations to complete
wait_for_apt_lock

# Update package index
print_status "Updating package index..."
sudo apt-get update

# Upgrade packages
print_status "Upgrading packages..."
wait_for_apt_lock
sudo apt-get upgrade -y

# Install prerequisites
print_status "Installing prerequisites..."
wait_for_apt_lock
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

# Install Docker
print_status "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

wait_for_apt_lock
sudo apt-get update

wait_for_apt_lock
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to docker group
if [ "$RUNNING_AS_ROOT" = false ]; then
    print_status "Adding current user to docker group..."
    sudo usermod -aG docker $USER
    print_warning "You will need to log out and log back in for docker group membership to take effect."
else
    print_status "Skipping docker group configuration (running as root)..."
fi

# Install Tailscale
print_status "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

# Validate installations
validate_installation

print_status "Infrastructure installation completed successfully!"

if [ "$RUNNING_AS_ROOT" = false ]; then
    print_warning "IMPORTANT: Please log out and log back in to apply the docker group membership changes."
    print_status "After logging back in, you can verify Docker works without sudo by running: docker ps"
fi
