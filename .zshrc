#!/usr/bin/env zsh
# ==============================================
# ZSH Configuration File
# ==============================================

# ----------------------------------------------
# Oh My ZSH Configuration
# ----------------------------------------------

export ZSH="$HOME/.oh-my-zsh"

zstyle ':omz:update' mode auto
ZSH_THEME="agnoster"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"

plugins=(git)

source "$ZSH/oh-my-zsh.sh"

# ----------------------------------------------
# Environment Variables
# ----------------------------------------------

export EDITOR='nvim'
export VISUAL='nvim'
export PATH="$HOME/.local/bin:$PATH"

# Neovim (if installed to /opt)
[[ -d "/opt/nvim/bin" ]] && export PATH="/opt/nvim/bin:$PATH"

# Android SDK (if exists)
if [[ -d "$HOME/Library/Android/sdk" ]]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
elif [[ -d "$HOME/Android/Sdk" ]]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
fi
[[ -n "$ANDROID_HOME" ]] && export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/emulator"

# Java (detect installation)
if [[ "$OSTYPE" == darwin* ]]; then
    if [[ -d "/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home" ]]; then
        export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
    elif [[ -x "/usr/libexec/java_home" ]]; then
        export JAVA_HOME="$(/usr/libexec/java_home 2>/dev/null)" || true
    fi
else
    for jvm in "/usr/lib/jvm/java-17-openjdk-amd64" "/usr/lib/jvm/java-17-openjdk"; do
        [[ -d "$jvm" ]] && { export JAVA_HOME="$jvm"; break; }
    done
fi

# ----------------------------------------------
# NVM (lazy loading for faster shell startup)
# ----------------------------------------------

export NVM_DIR="$HOME/.nvm"

# Lazy load NVM - only initialize when first called
nvm() {
    unset -f nvm node npm npx
    [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
    nvm "$@"
}

node() {
    unset -f nvm node npm npx
    [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
    node "$@"
}

npm() {
    unset -f nvm node npm npx
    [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
    npm "$@"
}

npx() {
    unset -f nvm node npm npx
    [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
    npx "$@"
}

# ----------------------------------------------
# SSH Keys (quiet, only if agent running)
# ----------------------------------------------

_load_ssh_keys() {
    # Only run if ssh-agent is available
    command -v ssh-add &>/dev/null || return

    local keys=("$HOME/.ssh/id_ed25519" "$HOME/.ssh/id_personal" "$HOME/.ssh/id_work")
    local loaded=$(ssh-add -l 2>/dev/null)

    for key in "${keys[@]}"; do
        [[ -f "$key" ]] || continue
        echo "$loaded" | grep -q "$(basename "$key")" && continue

        if [[ "$OSTYPE" == darwin* ]]; then
            ssh-add --apple-use-keychain "$key" 2>/dev/null
        else
            ssh-add "$key" 2>/dev/null
        fi
    done
}
_load_ssh_keys

# ----------------------------------------------
# Aliases
# ----------------------------------------------

# System
alias refresh="source ~/.zshrc"
alias zshrc="$EDITOR ~/.zshrc"
alias sshconfig="$EDITOR ~/.ssh/config"
alias dotfiles="cd ~/dotfiles"

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
    alias ll="ls -lah"
    alias la="ls -A"
fi

# ----------------------------------------------
# zoxide (smart cd replacement)
# ----------------------------------------------

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
    alias cd="z"
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
    n/p Next/Previous window
    ,   Rename window
    &   Kill window
    0-9 Switch to window #

  PANES (splits):
    %   Split vertical
    \"   Split horizontal
    ←→↑↓ Navigate panes
    x   Kill pane
    z   Toggle zoom

  OTHER:
    d   Detach
    ?   List keybindings
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"'

# ----------------------------------------------
# Platform-Specific Configuration
# ----------------------------------------------

if [[ "$OSTYPE" == linux* ]]; then
    alias update-all='sudo apt update && sudo apt upgrade -y && flatpak update -y 2>/dev/null; echo "Updates complete."'
    alias open="xdg-open"
elif [[ "$OSTYPE" == darwin* ]]; then
    alias update-all="brew update && brew upgrade"
fi

# ----------------------------------------------
# Work/Local Configuration (load if exists)
# ----------------------------------------------

[[ -f "$HOME/.zshrc.work" ]] && source "$HOME/.zshrc.work"
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# ----------------------------------------------
# Final Settings
# ----------------------------------------------

unsetopt correct_all

# aliases command - show all custom aliases
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

  DOTFILES:
    dotfiles       → cd ~/dotfiles

  UTILITIES:
    rsync          → With progress
    tmux-help      → Show tmux cheatsheet
    update-all     → Update system packages
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    [[ $(typeset -f lsaliases) ]] && echo "\n  Run 'lsaliases' for work-specific aliases"
}
