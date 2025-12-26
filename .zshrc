#!/usr/bin/env zsh
# ==============================================
# ZSH Configuration File
# ==============================================

# ----------------------------------------------
# Oh My ZSH Configuration
# ----------------------------------------------

export ZSH="$HOME/.oh-my-zsh"

# OMZ settings
zstyle ':omz:update' mode auto
ZSH_THEME="agnoster"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"

# Plugins
plugins=(git)

# Initialize Oh My ZSH
source "$ZSH/oh-my-zsh.sh"

# ----------------------------------------------
# Environment Variables
# ----------------------------------------------

# Editor
export EDITOR='nvim'
export VISUAL='nvim'

# Local bin (pipx, etc.)
export PATH="$HOME/.local/bin:$PATH"

# Neovim (if installed to /opt)
[[ -d "/opt/nvim/bin" ]] && export PATH="/opt/nvim/bin:$PATH"

# Android SDK (if exists)
if [[ -d "$HOME/Library/Android/sdk" ]]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
elif [[ -d "$HOME/Android/Sdk" ]]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
fi

if [[ -n "$ANDROID_HOME" ]]; then
    export PATH="$PATH:$ANDROID_HOME/platform-tools"
    export PATH="$PATH:$ANDROID_HOME/tools"
    export PATH="$PATH:$ANDROID_HOME/tools/bin"
    export PATH="$PATH:$ANDROID_HOME/emulator"
fi

# Java (detect installation)
if [[ "$OSTYPE" == darwin* ]]; then
    # macOS - check common locations
    if [[ -d "/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home" ]]; then
        export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
    elif [[ -x "/usr/libexec/java_home" ]]; then
        export JAVA_HOME="$(/usr/libexec/java_home 2>/dev/null)" || true
    fi
else
    # Linux - check common locations
    if [[ -d "/usr/lib/jvm/java-17-openjdk-amd64" ]]; then
        export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
    elif [[ -d "/usr/lib/jvm/java-17-openjdk" ]]; then
        export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
    fi
fi

# NVM
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"

# ----------------------------------------------
# SSH Keys (quiet, only if keys exist)
# ----------------------------------------------

load_ssh_key() {
    local key="$1"
    [[ -f "$key" ]] || return
    
    # Check if key is already loaded
    ssh-add -l 2>/dev/null | grep -q "$(basename "$key")" && return
    
    if [[ "$OSTYPE" == darwin* ]]; then
        ssh-add --apple-use-keychain "$key" 2>/dev/null
    else
        ssh-add "$key" 2>/dev/null
    fi
}

# Load keys if they exist
load_ssh_key "$HOME/.ssh/id_ed25519"
load_ssh_key "$HOME/.ssh/id_personal"
load_ssh_key "$HOME/.ssh/id_work"

# ----------------------------------------------
# Aliases
# ----------------------------------------------

# System
alias refresh="source ~/.zshrc"
alias zshrc="$EDITOR ~/.zshrc"
alias sshconfig="$EDITOR ~/.ssh/config"

# Neovim
alias vi="nvim"
alias vim="nvim"

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Safety
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# rsync with progress
alias rsync="rsync -az --info=progress2"

# ----------------------------------------------
# eza (modern ls replacement)
# ----------------------------------------------

if command -v eza &>/dev/null; then
    alias ls="eza --icons --group-directories-first"
    alias ll="eza -la --icons --group-directories-first"
    alias la="eza -a --icons --group-directories-first"
    alias lt="eza --tree --icons --group-directories-first"
    alias tree="eza --tree --icons --group-directories-first"
else
    # Fallback to standard ls
    alias ll="ls -lah"
    alias la="ls -A"
fi

# Gentle reminders for old habits
_ls_reminder() {
    echo "💡 Tip: You're using eza! Try: ll, la, lt (tree view)" >&2
}

# ----------------------------------------------
# zoxide (smart cd replacement)
# ----------------------------------------------

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
    
    # Alias cd to z for muscle memory, but keep cd available
    alias cd="z"
    
    # Reminder function
    _cd_reminder() {
        echo "💡 Tip: Using zoxide! 'z' learns your frequent dirs. Try: z <partial-path>, zi (interactive)" >&2
    }
fi

# ----------------------------------------------
# tmux
# ----------------------------------------------

alias tmux-help='echo "
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  TMUX QUICK START
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Start:          tmux
  New session:    tmux new -s <name>
  Attach:         tmux attach -t <name>
  List sessions:  tmux ls
  Kill session:   tmux kill-session -t <name>

  PREFIX KEY: Ctrl+b (then release, then command)

  WINDOWS (tabs):
    c   Create window
    n   Next window
    p   Previous window
    ,   Rename window
    &   Kill window
    0-9 Switch to window #

  PANES (splits):
    %   Split vertical
    \"   Split horizontal
    ←→↑↓ Navigate panes
    x   Kill pane
    z   Toggle zoom (fullscreen pane)

  OTHER:
    d   Detach (exit but keep running)
    ?   List all keybindings
    :   Command mode
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"'

# ----------------------------------------------
# Platform-Specific Configuration
# ----------------------------------------------

if [[ "$OSTYPE" == linux* ]]; then
    # Linux-specific aliases
    alias update-all='sudo apt update && sudo apt upgrade -y && flatpak update -y 2>/dev/null; echo "Updates complete."'
    alias open="xdg-open"
fi

if [[ "$OSTYPE" == darwin* ]]; then
    # macOS-specific aliases
    alias update-all="brew update && brew upgrade"
fi

# ----------------------------------------------
# Work Configuration (optional, load if exists)
# ----------------------------------------------

[[ -f "$HOME/.zshrc.work" ]] && source "$HOME/.zshrc.work"

# ----------------------------------------------
# Local Configuration (optional, load if exists)
# ----------------------------------------------

[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# ----------------------------------------------
# Final Settings
# ----------------------------------------------

unsetopt correct_all  # Disable auto-correct

# aliases command - show all custom aliases
# (unalias first in case .zshrc.work defined it)
unalias aliases 2>/dev/null
aliases() {
    echo "
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  AVAILABLE ALIASES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  EDITOR:
    vi, vim        → nvim
    zshrc          → Edit ~/.zshrc
    sshconfig      → Edit ~/.ssh/config
    refresh        → Reload .zshrc

  FILES (eza):
    ls             → eza with icons
    ll             → Long list
    la             → Show hidden
    lt, tree       → Tree view

  NAVIGATION (zoxide):
    cd / z         → Smart cd (learns your dirs)
    zi             → Interactive directory picker
    z <partial>    → Jump to matching dir

  SAFETY:
    rm, cp, mv     → Interactive (confirm before overwrite)

  UTILITIES:
    rsync          → With progress
    tmux-help      → Show tmux cheatsheet
    update-all     → Update system packages

  SHORTCUTS:
    ..             → cd ..
    ...            → cd ../..
    ....           → cd ../../..
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Show work aliases if available
    if typeset -f lsaliases > /dev/null; then
        echo ""
        echo "  Run 'lsaliases' for work-specific aliases"
    fi
}

# thefuck integration (if installed and working)
if command -v thefuck &>/dev/null; then
    eval "$(thefuck --alias 2>/dev/null)" 2>/dev/null || true
fi
