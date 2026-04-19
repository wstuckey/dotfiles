#!/usr/bin/env zsh
# ==============================================
# ZSH Configuration File
# ==============================================

# ----------------------------------------------
# Oh My ZSH
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

export EDITOR='nano'
export VISUAL='code --wait'
export PATH="$HOME/.local/bin:$PATH"
export AWS_PROFILE=cartographer

# Android SDK
if [[ -d "$HOME/Library/Android/sdk" ]]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
elif [[ -d "$HOME/Android/Sdk" ]]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
fi
[[ -n "$ANDROID_HOME" ]] && export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/emulator"

# Java
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
# Tools
# ----------------------------------------------

# NVM (lazy loading for faster shell startup)
export NVM_DIR="$HOME/.nvm"

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

# zoxide (smart cd replacement)
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
    alias cd="z"
fi

# eza (modern ls replacement)
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
# SSH Keys (quiet, only if agent running)
# ----------------------------------------------

_load_ssh_keys() {
    command -v ssh-add &>/dev/null || return

    local keys=("$HOME/.ssh/id_ed25519" "$HOME/.ssh/id_personal" "$HOME/.ssh/id_work")
    local loaded=$(ssh-add -l 2>/dev/null)

    for key in "${keys[@]}"; do
        [[ -f "$key" ]] || continue
        local fp=$(ssh-keygen -lf "$key" 2>/dev/null | awk '{print $2}')
        [[ -n "$fp" ]] && echo "$loaded" | grep -q "$fp" && continue

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

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias dotfiles="cd ~/dotfiles"

# Safety
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# System
alias refresh="source ~/.zshrc"
alias zshrc="$EDITOR ~/.zshrc"
alias rsync="rsync -az --info=progress2"

# Platform-specific
if [[ "$OSTYPE" == linux* ]]; then
    alias update-all='sudo apt update && sudo apt upgrade -y && flatpak update -y 2>/dev/null; rm -f "$HOME/.local/share/update-check-status"; echo "Updates complete."'
    alias open="xdg-open"
elif [[ "$OSTYPE" == darwin* ]]; then
    alias update-all="brew update && brew upgrade"
fi

# tmux
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

# SSH editing
alias sshedit="nano ~/dotfiles/ssh/config && cp ~/dotfiles/ssh/config ~/.ssh/config && chmod 600 ~/.ssh/config"

unalias sshworkedit 2>/dev/null
if [[ -f "$HOME/.ssh/config.work" ]]; then
    sshworkedit() {
        nano ~/dotfiles-work/ssh/config.work && cp ~/dotfiles-work/ssh/config.work ~/.ssh/config.work && chmod 600 ~/.ssh/config.work
        echo "Updated ~/.ssh/config.work from dotfiles-work"
    }
fi

# ----------------------------------------------
# Functions
# ----------------------------------------------

unalias sshconfig 2>/dev/null
sshconfig() {
    local c="\033[36m" d="\033[2m" b="\033[1m" r="\033[0m"
    echo ""
    echo "  ${b}${c}SSH Hosts${r}"
    echo ""

    local personal=$(grep -i '^Host ' ~/.ssh/config 2>/dev/null | awk '{print $2}' | grep -v '\*')
    if [[ -n "$personal" ]]; then
        echo "  ${c}personal${r}  ${personal//$'\n'/  }"
    fi

    if [[ -f "$HOME/.ssh/config.work" ]]; then
        local section=""
        local sites="" builds="" vms=""
        while IFS= read -r line; do
            if [[ "$line" == *"Work Sites"* ]]; then section="sites"
            elif [[ "$line" == *"Build Machines"* ]]; then section="builds"
            elif [[ "$line" == *"Virtual Machines"* ]]; then section="vms"
            elif [[ "$line" == Host\ * ]]; then
                local host="${line#Host }"
                case "$section" in
                    sites) sites+="$host  " ;;
                    builds) builds+="$host  " ;;
                    vms) vms+="$host  " ;;
                esac
            fi
        done < ~/.ssh/config.work
        [[ -n "$sites" ]] && echo "  ${c}sites${r}     $sites"
        [[ -n "$builds" ]] && echo "  ${c}builds${r}    $builds"
        [[ -n "$vms" ]] && echo "  ${c}vms${r}       $vms"
    fi

    echo ""
    echo "  ${d}sshedit to edit personal config${r}"
    [[ -f "$HOME/.ssh/config.work" ]] && echo "  ${d}sshworkedit to edit work config${r}"
    echo ""
}

# ----------------------------------------------
# Work/Local Configuration (load if exists)
# ----------------------------------------------

[[ -f "$HOME/.zshrc.work" ]] && source "$HOME/.zshrc.work"
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# ----------------------------------------------
# Startup
# ----------------------------------------------

unsetopt correct_all

# Pop!_OS update check
if [[ -f /etc/os-release ]] && grep -qi 'pop' /etc/os-release; then
    if [[ -f "$HOME/.local/share/update-check-status" ]]; then
        source "$HOME/.local/share/update-check-status"
        echo ""
        echo -e "\033[1;33m── Updates Available ──\033[0m"
        if [[ "$APT_COUNT" -gt 0 ]]; then
            echo -e "\033[33m$APT_COUNT apt package(s) upgradable:\033[0m"
            echo "$PKG_NAMES" | head -10 | sed 's/^/  /'
            [[ "$APT_COUNT" -gt 10 ]] && echo "  …and $((APT_COUNT - 10)) more"
            echo -e "\033[1mRun:\033[0m update-all"
        fi
        if echo "$POP_MSG" | grep -q "⬆"; then
            echo ""
            echo -e "\033[33m$POP_MSG\033[0m"
            echo -e "\033[1mRun:\033[0m pop-upgrade release upgrade"
        fi
        echo -e "\033[1;33m───────────────────────\033[0m"
        echo ""
    fi
fi

# Alias summary
unalias aliases 2>/dev/null
aliases() {
    local c="\033[36m" d="\033[2m" b="\033[1m" r="\033[0m"
    echo ""
    echo "  ${b}${c}Aliases${r}"
    echo ""
    if [[ -f "$HOME/.ssh/config.work" ]]; then
        echo "  ${c}edit${r}     zshrc   sshedit   sshworkedit"
    else
        echo "  ${c}edit${r}     zshrc   sshedit"
    fi
    echo "  ${c}files${r}    ls   ll   la   lt   tree"
    echo "  ${c}nav${r}      ..   ...   ....   dotfiles   cd/z   zi"
    echo "  ${c}safety${r}   rm   cp   mv"
    echo "  ${c}utils${r}    refresh   rsync   tmux-help   update-all"
    if [[ -f "$HOME/.zshrc.work" ]]; then
        echo ""
        echo "  ${b}${c}Work Aliases${r}"
        echo ""
        echo "  ${c}deploy${r}   site-pushSSH   site-pushRsync   pushDebug"
        echo "  ${c}tools${r}    genlic   hui-sync   uidd_builder   mass-hui-revert   buildDocs"
        echo "  ${c}nav${r}      cd-feature   cd-trunk   cd-doctor"
        echo "  ${c}node${r}     node18   node20   node21   node22   node23"
        echo "  ${c}carto${r}    aws sso login  ${d}— authenticate with AWS SSO${r}"
        echo "           cartographer_token [prod|staging]  ${d}— fetch OAuth2 token${r}"
        echo "           cartographer_admin [--staging] ...  ${d}— run admin.sh${r}"
    fi
    echo ""
    echo "  ${d}run 'sshconfig' for ssh hosts${r}"
    echo ""
}
