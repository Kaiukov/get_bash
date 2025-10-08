#!/bin/bash

# Script to install Node.js, Claude Code, and Qwen Code
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

# Validate installed packages
validate_installation() {
    print_status "Validating installations..."

    local all_valid=true

    # Check Node.js
    if command -v node &> /dev/null; then
        print_status "✓ Node.js is installed. Version: $(node --version)"
    else
        print_error "✗ Node.js installation failed!"
        all_valid=false
    fi

    # Check npm
    if command -v npm &> /dev/null; then
        print_status "✓ npm is installed. Version: $(npm --version)"
    else
        print_error "✗ npm installation failed!"
        all_valid=false
    fi

    # Check Claude Code
    if command -v claude &> /dev/null; then
        print_status "✓ Claude Code is installed. Version: $(claude --version 2>&1 | head -n 1 || echo 'installed')"
    else
        print_error "✗ Claude Code installation failed!"
        all_valid=false
    fi

    # Check Qwen Code
    if command -v qwen &> /dev/null; then
        print_status "✓ Qwen Code is installed. Version: $(qwen --version 2>&1 | head -n 1 || echo 'installed')"
    else
        print_error "✗ Qwen Code installation failed!"
        all_valid=false
    fi

    if [ "$all_valid" = false ]; then
        exit 1
    fi
}

print_status "Starting installation of Node.js, Claude Code, and Qwen Code..."

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

# Verify Node.js and npm are available
print_status "Validating Node.js and npm installation..."
if ! node --version >/dev/null 2>&1 || ! npm --version >/dev/null 2>&1; then
    print_error "Node.js or npm installation failed!"
    print_error "Please ensure NVM loaded correctly and try again."
    exit 1
fi

print_status "✓ Node.js $(node --version) and npm $(npm --version) are available"

# Install Claude Code globally via npm
print_status "Installing Claude Code..."
npm install -g @anthropic-ai/claude-code

# Install Qwen Code globally via npm
print_status "Installing Qwen Code..."
npm install -g @qwen-code/qwen-code

# Validate installations
validate_installation

print_status "Development tools installation completed successfully!"
print_status ""
print_status "Next steps:"
print_status "1. Restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
print_status "2. Verify installations:"
print_status "   - node --version"
print_status "   - npm --version"
print_status "   - claude --version"
print_status "   - qwen --version"
