#!/bin/bash

# setup.sh - System setup and configuration script
#
# This script automates the setup of a development environment including:
# - Package manager installation (Homebrew for Mac, apt for Linux)
# - Core tools installation (Zsh, Git, cURL)
# - Oh My Zsh configuration
# - Rust toolchain installation
# - Micro editor installation
# - Dotfiles setup
# - Optional GitHub SSH keys configuration
#
# The script is designed to work on both macOS and Linux systems.
# On Linux systems, sudo privileges are required but only requested once.

# Store sudo password at the beginning of the script if needed
# This ensures the user only has to enter it once
SUDO_PASSWORD=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    read -sp "Enter your sudo password: " SDO_PASSWORD
    echo
fi

# If Mac, install Homebrew
if [[ "$OSTYPE" == "darwin"* ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Zsh, Git, and (if on linux) cURL
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Use the stored password for all sudo commands
  echo "$SUDO_PASSWORD" | sudo -S apt update && echo "$SUDO_PASSWORD" | sudo -S apt install -y zsh git curl
elif [[ "$OSTYPE" == "darwin"* ]]; then
  brew install zsh git
fi

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -y

# Install Micro
curl https://getmic.ro | bash

# Clone dotfiles and symlink .zshrc
git clone https://github.com/wstuckey/dotfiles.git ~/dotfiles
ln -sf ~/dotfiles/.zshrc ~/.zshrc

# Change shell to Zsh (if not already)
# Note: chsh typically requires password, using stored password if Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "$SUDO_PASSWORD" | sudo -S chsh -s $(which zsh)
else
    chsh -s $(which zsh)
fi

# Reload shell
source ~/.zshrc

# Ask about adding GitHub keys
read -p "Would you like to add GitHub public keys to your known_hosts? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter GitHub username: " github_username
    KNOWN_HOSTS_FILE="$HOME/.ssh/known_hosts"
    TMP_FILE=$(mktemp)
    
    # Create .ssh directory if it doesn't exist
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    
    # Get SSH keys from GitHub
    echo "Fetching SSH keys for GitHub user $github_username..."
    curl -s "https://github.com/$github_username.keys" > "$TMP_FILE"
    
    # Check if we got any keys
    if [ ! -s "$TMP_FILE" ]; then
        echo "No SSH keys found for user $github_username or failed to fetch."
        rm "$TMP_FILE"
        exit 1
    fi
    
    # Process each key
    while read -r key; do
        if [ -n "$key" ]; then
            # Format the key for known_hosts: github.com + key
            formatted_entry="github.com ssh-rsa $key"
            
            # Check if the key already exists in known_hosts
            if grep -Fq "$key" "$KNOWN_HOSTS_FILE" 2>/dev/null; then
                echo "Key already exists in known_hosts:"
                echo "$key"
            else
                echo "Adding key to known_hosts:"
                echo "$key"
                echo "$formatted_entry" >> "$KNOWN_HOSTS_FILE"
            fi
        fi
    done < "$TMP_FILE"
    
    # Clean up
    rm "$TMP_FILE"
    
    # Set proper permissions for known_hosts
    chmod 644 ~/.ssh/known_hosts
    
    echo "GitHub keys have been added to $KNOWN_HOSTS_FILE"
fi

# Clear the stored password for security
SUDO_PASSWORD=""

# finito!
echo "Done! Enjoy your new environment."
