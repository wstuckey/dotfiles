#!/bin/bash

# setup.sh - System setup and configuration script
#
# This script automates the setup of a development environment including:
# - Package manager setup (Homebrew for Mac, apt for Linux)
# - Core tools: Zsh, Git, cURL
# - Oh My Zsh
# - Python + pipx
# - Node.js via NVM
# - OpenJDK 17
# - Neovim
# - SSH keys and config
# - Dotfiles symlinks
#
# Usage:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/wstuckey/dotfiles/main/setup.sh)"

set -e  # Exit on error

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------

print_section() {
    echo ""
    echo "======================================"
    echo "$1"
    echo "======================================"
}

print_info() {
    echo "→ $1"
}

print_success() {
    echo "✓ $1"
}

print_warning() {
    echo "⚠ $1"
}

command_exists() {
    command -v "$1" &> /dev/null
}

# ------------------------------------------------------------------------------
# Sudo Setup (Linux only)
# ------------------------------------------------------------------------------

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "This script requires sudo privileges for package installation."
    sudo -v
    
    # Keep sudo alive throughout the script
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

# ------------------------------------------------------------------------------
# Package Manager Setup
# ------------------------------------------------------------------------------

print_section "Setting up package manager"

if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command_exists brew; then
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        print_success "Homebrew already installed"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    print_info "Updating apt..."
    sudo apt update
fi

# ------------------------------------------------------------------------------
# Core Tools
# ------------------------------------------------------------------------------

print_section "Installing core tools (Zsh, Git, cURL)"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt install -y zsh git curl
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install zsh git curl
fi

# ------------------------------------------------------------------------------
# Oh My Zsh
# ------------------------------------------------------------------------------

print_section "Installing Oh My Zsh"

if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_success "Oh My Zsh already installed"
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ------------------------------------------------------------------------------
# Python & pipx
# ------------------------------------------------------------------------------

print_section "Installing Python and pipx"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt install -y python3 python3-pip python3-venv pipx
    pipx ensurepath
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install python pipx
    pipx ensurepath
fi

# ------------------------------------------------------------------------------
# OpenJDK
# ------------------------------------------------------------------------------

print_section "Installing OpenJDK 17"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt install -y openjdk-17-jdk
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install openjdk@17
    sudo ln -sfn "$(brew --prefix)/opt/openjdk@17/libexec/openjdk.jdk" /Library/Java/JavaVirtualMachines/openjdk-17.jdk
fi

# ------------------------------------------------------------------------------
# Neovim
# ------------------------------------------------------------------------------

print_section "Installing Neovim"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    NVIM_VERSION="v0.10.2"
    if [[ -d "/opt/nvim" ]]; then
        print_success "Neovim already installed"
    else
        print_info "Downloading Neovim ${NVIM_VERSION}..."
        curl -LO "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux64.tar.gz"
        sudo rm -rf /opt/nvim
        sudo tar -C /opt -xzf nvim-linux64.tar.gz
        sudo mv /opt/nvim-linux64 /opt/nvim
        rm nvim-linux64.tar.gz
        print_success "Neovim installed to /opt/nvim"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if command_exists nvim; then
        print_success "Neovim already installed"
    else
        brew install neovim
        print_success "Neovim installed via Homebrew"
    fi
fi

# Install Neovim dependencies
print_info "Installing Neovim dependencies..."

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # ripgrep and fd for Telescope
    sudo apt install -y ripgrep fd-find
    # Create fd symlink (Ubuntu names it fdfind)
    if [[ -x "$(command -v fdfind)" ]] && [[ ! -x "$(command -v fd)" ]]; then
        sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install ripgrep fd
fi

print_success "Neovim dependencies installed"

# ------------------------------------------------------------------------------
# eza (modern ls replacement)
# ------------------------------------------------------------------------------

print_section "Installing eza"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # eza requires adding the repository on Ubuntu
    if ! command_exists eza; then
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install eza
fi

print_success "eza installed"

# ------------------------------------------------------------------------------
# zoxide (smart cd replacement)
# ------------------------------------------------------------------------------

print_section "Installing zoxide"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if ! command_exists zoxide; then
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install zoxide
fi

print_success "zoxide installed"

# ------------------------------------------------------------------------------
# tmux
# ------------------------------------------------------------------------------

print_section "Installing tmux"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt install -y tmux
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install tmux
fi

print_success "tmux installed"

# ------------------------------------------------------------------------------
# Node.js via NVM
# ------------------------------------------------------------------------------

print_section "Installing NVM and Node.js"

export NVM_DIR="$HOME/.nvm"

if [[ -d "$NVM_DIR" ]]; then
    print_success "NVM already installed"
else
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# Load NVM
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

print_info "Installing Node.js LTS..."
nvm install --lts
nvm alias default 'lts/*'

# ------------------------------------------------------------------------------
# Dotfiles
# ------------------------------------------------------------------------------

print_section "Setting up dotfiles"

# Determine the real user's home directory (handles sudo case)
if [[ -n "$SUDO_USER" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        REAL_HOME=$(dscl . -read /Users/"$SUDO_USER" NFSHomeDirectory | awk '{print $2}')
    else
        REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    fi
    REAL_USER="$SUDO_USER"
else
    REAL_HOME="$HOME"
    REAL_USER="$(whoami)"
fi

DOTFILES_DIR="$REAL_HOME/dotfiles"

if [[ -d "$DOTFILES_DIR" ]]; then
    print_info "Dotfiles directory already exists, pulling latest..."
    cd "$DOTFILES_DIR" && git pull || true
else
    print_info "Cloning dotfiles..."
    git clone https://github.com/wstuckey/dotfiles.git "$DOTFILES_DIR"
    # Fix ownership if running as root
    [[ -n "$SUDO_USER" ]] && chown -R "$SUDO_USER:$SUDO_USER" "$DOTFILES_DIR"
fi

# Backup existing .zshrc if it exists and isn't a symlink
if [[ -f "$REAL_HOME/.zshrc" && ! -L "$REAL_HOME/.zshrc" ]]; then
    print_info "Backing up existing .zshrc to .zshrc.backup"
    mv "$REAL_HOME/.zshrc" "$REAL_HOME/.zshrc.backup"
fi

# Create symlink
ln -sf "$DOTFILES_DIR/.zshrc" "$REAL_HOME/.zshrc"
[[ -n "$SUDO_USER" ]] && chown -h "$SUDO_USER:$SUDO_USER" "$REAL_HOME/.zshrc"
print_success "Symlinked .zshrc"

# ------------------------------------------------------------------------------
# Neovim Configuration
# ------------------------------------------------------------------------------

print_section "Setting up Neovim configuration"

NVIM_CONFIG_DIR="$REAL_HOME/.config/nvim"
DOTFILES_NVIM_DIR="$DOTFILES_DIR/nvim"

# Create ~/.config if it doesn't exist
mkdir -p "$REAL_HOME/.config"
[[ -n "$SUDO_USER" ]] && chown "$SUDO_USER:$SUDO_USER" "$REAL_HOME/.config"

if [[ -d "$DOTFILES_NVIM_DIR" ]]; then
    # Backup existing nvim config if it exists and isn't a symlink
    if [[ -d "$NVIM_CONFIG_DIR" && ! -L "$NVIM_CONFIG_DIR" ]]; then
        print_info "Backing up existing Neovim config to nvim.backup"
        mv "$NVIM_CONFIG_DIR" "$REAL_HOME/.config/nvim.backup"
    elif [[ -L "$NVIM_CONFIG_DIR" ]]; then
        # Remove existing symlink
        rm "$NVIM_CONFIG_DIR"
    fi
    
    # Create symlink
    ln -sf "$DOTFILES_NVIM_DIR" "$NVIM_CONFIG_DIR"
    [[ -n "$SUDO_USER" ]] && chown -h "$SUDO_USER:$SUDO_USER" "$NVIM_CONFIG_DIR"
    print_success "Symlinked Neovim config"
    
    # Install plugins on first run (as the real user, not root)
    print_info "Installing Neovim plugins (this may take a moment)..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        NVIM_CMD="/opt/nvim/bin/nvim"
    else
        NVIM_CMD="nvim"
    fi
    
    if [[ -n "$SUDO_USER" ]]; then
        sudo -u "$SUDO_USER" "$NVIM_CMD" --headless "+Lazy! sync" +qa 2>/dev/null || true
    else
        "$NVIM_CMD" --headless "+Lazy! sync" +qa 2>/dev/null || true
    fi
    print_success "Neovim plugins installed"
else
    print_warning "Neovim config not found in dotfiles. Skipping."
    echo "  Expected: $DOTFILES_NVIM_DIR"
    echo "  Copy your nvim config there and re-run setup."
fi

# ------------------------------------------------------------------------------
# SSH Setup
# ------------------------------------------------------------------------------

print_section "Setting up SSH"

SSH_DIR="$REAL_HOME/.ssh"
DOTFILES_SSH_DIR="$DOTFILES_DIR/ssh"

# Create ~/.ssh with proper permissions
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
[[ -n "$SUDO_USER" ]] && chown "$SUDO_USER:$SUDO_USER" "$SSH_DIR"

# Symlink SSH config
if [[ -f "$DOTFILES_SSH_DIR/config" ]]; then
    if [[ -f "$SSH_DIR/config" && ! -L "$SSH_DIR/config" ]]; then
        print_info "Backing up existing SSH config"
        mv "$SSH_DIR/config" "$SSH_DIR/config.backup"
    fi
    ln -sf "$DOTFILES_SSH_DIR/config" "$SSH_DIR/config"
    chmod 600 "$SSH_DIR/config"
    [[ -n "$SUDO_USER" ]] && chown -h "$SUDO_USER:$SUDO_USER" "$SSH_DIR/config"
    print_success "Symlinked SSH config"
fi

# Check for SSH keys
SSH_KEYS_NEEDED=()
[[ ! -f "$DOTFILES_SSH_DIR/id_personal" ]] && SSH_KEYS_NEEDED+=("id_personal")
[[ ! -f "$DOTFILES_SSH_DIR/id_personal.pub" ]] && SSH_KEYS_NEEDED+=("id_personal.pub")
[[ ! -f "$DOTFILES_SSH_DIR/id_work" ]] && SSH_KEYS_NEEDED+=("id_work")
[[ ! -f "$DOTFILES_SSH_DIR/id_work.pub" ]] && SSH_KEYS_NEEDED+=("id_work.pub")

if [[ ${#SSH_KEYS_NEEDED[@]} -gt 0 ]]; then
    echo ""
    print_warning "SSH keys not found in dotfiles!"
    echo ""
    echo "Please copy your SSH keys to: $DOTFILES_SSH_DIR/"
    echo ""
    echo "Required files:"
    for key in "${SSH_KEYS_NEEDED[@]}"; do
        echo "  - $key"
    done
    echo ""
    echo "Example:"
    echo "  cp ~/.ssh/id_personal $DOTFILES_SSH_DIR/"
    echo "  cp ~/.ssh/id_personal.pub $DOTFILES_SSH_DIR/"
    echo "  cp ~/.ssh/id_work $DOTFILES_SSH_DIR/"
    echo "  cp ~/.ssh/id_work.pub $DOTFILES_SSH_DIR/"
    echo ""
    read -p "Press Enter once you've added the keys (or 's' to skip): " -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        # Re-check for keys
        SSH_KEYS_NEEDED=()
        [[ ! -f "$DOTFILES_SSH_DIR/id_personal" ]] && SSH_KEYS_NEEDED+=("id_personal")
        [[ ! -f "$DOTFILES_SSH_DIR/id_work" ]] && SSH_KEYS_NEEDED+=("id_work")
        
        if [[ ${#SSH_KEYS_NEEDED[@]} -gt 0 ]]; then
            print_warning "Keys still missing. Skipping SSH key setup."
        fi
    fi
fi

# Copy and set up SSH keys
setup_ssh_key() {
    local key_name="$1"
    local src="$DOTFILES_SSH_DIR/$key_name"
    local dest="$SSH_DIR/$key_name"
    
    if [[ -f "$src" ]]; then
        cp "$src" "$dest"
        chmod 600 "$dest"
        [[ -n "$SUDO_USER" ]] && chown "$SUDO_USER:$SUDO_USER" "$dest"
        print_success "Installed $key_name"
        return 0
    fi
    return 0  # Return success even if key doesn't exist
}

setup_ssh_pubkey() {
    local key_name="$1"
    local src="$DOTFILES_SSH_DIR/$key_name"
    local dest="$SSH_DIR/$key_name"
    
    if [[ -f "$src" ]]; then
        cp "$src" "$dest"
        chmod 644 "$dest"
        [[ -n "$SUDO_USER" ]] && chown "$SUDO_USER:$SUDO_USER" "$dest"
        print_success "Installed $key_name"
    fi
    return 0  # Always return success
}

# Install keys (skip silently if not present)
setup_ssh_key "id_personal"
setup_ssh_pubkey "id_personal.pub"
setup_ssh_key "id_work"
setup_ssh_pubkey "id_work.pub"

# Start ssh-agent and add keys
print_info "Adding keys to SSH agent..."

# Ensure ssh-agent is running
if [[ -z "$SSH_AUTH_SOCK" ]]; then
    eval "$(ssh-agent -s)" > /dev/null
fi

# Add keys to agent (silently skip if not present)
add_key_to_agent() {
    local key="$SSH_DIR/$1"
    [[ -f "$key" ]] || return 0  # Return success if key doesn't exist
    
    if [[ "$OSTYPE" == darwin* ]]; then
        ssh-add --apple-use-keychain "$key" 2>/dev/null && print_success "Added $1 to SSH agent (with keychain)"
    else
        ssh-add "$key" 2>/dev/null && print_success "Added $1 to SSH agent"
    fi
    return 0  # Always return success
}

add_key_to_agent "id_personal"
add_key_to_agent "id_work"

# ------------------------------------------------------------------------------
# Change Default Shell
# ------------------------------------------------------------------------------

print_section "Setting Zsh as default shell"

# Get the current shell for the real user
if [[ "$OSTYPE" == "darwin"* ]]; then
    CURRENT_SHELL=$(dscl . -read /Users/"$REAL_USER" UserShell | awk '{print $2}')
else
    CURRENT_SHELL=$(getent passwd "$REAL_USER" | cut -d: -f7)
fi

if [[ "$CURRENT_SHELL" != *"zsh"* ]]; then
    ZSH_PATH="$(which zsh)"
    print_info "Changing default shell to: $ZSH_PATH"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - chsh requires interactive password, inform user
        print_warning "macOS requires your password to change the default shell."
        if [[ -n "$SUDO_USER" ]]; then
            sudo -u "$SUDO_USER" chsh -s "$ZSH_PATH"
        else
            chsh -s "$ZSH_PATH"
        fi
    else
        # Linux
        chsh -s "$ZSH_PATH" "$REAL_USER"
    fi
    
    if [[ $? -eq 0 ]]; then
        print_success "Default shell changed to Zsh for $REAL_USER"
    else
        print_warning "Could not change shell automatically. Run manually: chsh -s $(which zsh)"
    fi
else
    print_success "Zsh is already the default shell"
fi

# ------------------------------------------------------------------------------
# Done
# ------------------------------------------------------------------------------

print_section "Setup Complete!"

echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: exec zsh"
echo "  2. Verify SSH keys: ssh-add -l"
echo "  3. Test SSH connections:"
echo "       ssh -T git@github.com"
echo "       ssh -T git@git.ein-softworks.com"
echo ""

# Show any warnings
if [[ ! -f "$SSH_DIR/id_personal" ]] || [[ ! -f "$SSH_DIR/id_work" ]]; then
    print_warning "Some SSH keys were not installed. Add them to $DOTFILES_SSH_DIR/ and re-run setup."
fi

echo ""
echo "Enjoy your new environment!"
