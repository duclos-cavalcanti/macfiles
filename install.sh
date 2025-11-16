#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CLEAR='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${CLEAR} $1"
}

print_section() {
    echo -e "${YELLOW}=== $1 ===${CLEAR}"
}

function install_brew() {
    print_section "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

function install_packages() {
    print_section "Installing packages from Brewfile"
    if [ -f "Brewfile" ]; then
        brew bundle install
        print_status "Packages installed successfully"
    else
        echo "Brewfile not found!"
        exit 1
    fi
}

function install_dotfiles() {
    print_section "Setting up dotfiles with stow"
    if [ -f "stow.sh" ]; then
        ./stow.sh --install
        print_status "Dotfiles installed successfully"
    else
        echo "stow.sh not found!"
        exit 1
    fi
}

function install_ai() {
    print_section "Installing AI tools"
    npm install -g @augmentcode/auggie
    npm install -g @github/copilot
}

function main() {
    print_status "Starting macfiles setup..."

    # Check if we're on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo "This script is designed for macOS only."
        exit 1
    fi

    install_brew
    install_packages
    install_dotfiles
    install_ai

    print_status "Setup complete!"
    echo
}

main "$@"
