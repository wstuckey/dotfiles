#!/usr/bin/env zsh
# ==============================================
# ZSH Configuration File
# Organized and optimized version
# ==============================================

# ----------------------------------------------
# Oh My ZSH Configuration
# ----------------------------------------------
export ZSH="$HOME/.oh-my-zsh"               # Path to oh-my-zsh installation

# OMZ settings
zstyle ':omz:update' mode auto              # Update automatically without asking
ZSH_THEME="agnoster"                        # See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ENABLE_CORRECTION="false"                   # Disable command auto-correction
COMPLETION_WAITING_DOTS="true"              # Show loading dots during completion

# Plugins
plugins=(git)                               # Load git plugin

# Initialize Oh My ZSH
source $ZSH/oh-my-zsh.sh

# ----------------------------------------------
# Environment Variables
# ----------------------------------------------

# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/emulator

# Java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # Load nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # Load nvm completion

# Rust
export PATH="$HOME/.cargo/bin:$PATH"
source "$HOME/.cargo/env"

# SSH (platform-dependent, added quietly)
if [[ "$OSTYPE" == darwin* ]]; then
    # macOS - use keychain
    ssh-add --apple-use-keychain ~/.ssh/id_personal >/dev/null 2>&1
    ssh-add --apple-use-keychain ~/.ssh/id_work >/dev/null 2>&1
else
    # Linux/other - standard ssh-add
    ssh-add ~/.ssh/id_personal >/dev/null 2>&1
    ssh-add ~/.ssh/id_work >/dev/null 2>&1
fi

# ----------------------------------------------
# Site Configuration
# ----------------------------------------------

# Site IP mapping
declare -A SITE_IPS=(
    ["site1"]="10.28.24.74"
    ["site2"]="10.28.24.77"
    ["site2wifi"]="10.73.83.43"
    ["site3"]="10.28.24.69"
)

# ----------------------------------------------
# Custom Functions
# ----------------------------------------------

# List aliases in a formatted way
function lsaliases() {
    setopt PROMPT_SUBST  # Enable prompt expansion for colors

    # Define colors
    local CYAN=$'\e[0;36m'     # For headers
    local YELLOW=$'\e[0;33m'   # For other aliases
    local PURPLE=$'\e[0;34m'   # For site1
    local RED=$'\e[0;31m'      # For site2
    local GREEN=$'\e[0;32m'    # For site3
    local MAGENTA=$'\e[0;35m'  # For other site prefixes
    local NC=$'\e[0m'          # No Color

    typeset -a site_aliases other_aliases

    # Get aliases defined in .zshrc
    while IFS= read -r line; do
        [[ $line =~ ^[[:space:]]*alias[[:space:]] ]] || continue

        # Extract alias name
        name=$(echo $line | sed 's/^[[:space:]]*alias[[:space:]]*\([^=]*\)=.*/\1/')
        name="${name## }"
        name="${name%% }"

        # Sort into appropriate array
        if [[ $name == site* ]]; then
            site_aliases+=($name)
        else
            other_aliases+=($name)
        fi
    done < $HOME/.zshrc

    # Sort arrays
    site_aliases=(${(o)site_aliases})
    other_aliases=(${(o)other_aliases})

    # Print headers
    printf "%b%-33s%s%b\n" "$CYAN" "Site-related aliases:" "Other custom aliases:" "$NC"

    # Print columns
    local max_length=$(( ${#site_aliases} > ${#other_aliases} ? ${#site_aliases} : ${#other_aliases} ))
    for ((i = 1; i <= max_length; i++)); do
        local site_str="" other_str=""

        # Site aliases column
        if (( i <= ${#site_aliases} )); then
            local alias=$site_aliases[i]
            case $alias in
                *1*) site_str="${PURPLE}  $alias" ;;
                *2*) site_str="${RED}  $alias" ;;
                *3*) site_str="${GREEN}  $alias" ;;
                *)   site_str="${MAGENTA}  $alias" ;;
            esac
        fi

        # Other aliases column
        if (( i <= ${#other_aliases} )); then
            other_str="${YELLOW}  $other_aliases[i]"
        fi

        printf "%b%-40s%s%b\n" "" "$site_str" "$other_str" "$NC"
    done
    print
}

# Generate license
function generate_license() {
    [[ -z "$1" ]] && { echo "Please provide a hardware serial number"; return 1 }
    lickitung generate $1 -o $1.lic
}

# Push debug helper
function helper-pushDebug() {
    # Usage:
    #   helper-pushDebug --site site1                           # Default syncdir "huiTest"
    #   helper-pushDebug --site site2 --syncdir huiBlah         # Custom syncdir
    #   helper-pushDebug --site site1 --clean                   # Add "clean" after grunt
    #   helper-pushDebug --site site2 --syncdir huiTest --clean # Combined options

    local site="" syncdir="huiTest" clean_flag=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --site) site="$2"; shift 2 ;;
            --syncdir) syncdir="$2"; shift 2 ;;
            --clean) clean_flag=true; shift ;;
            *)
                echo "Error: Unknown option $1"
                echo "Usage: pushDebug --site <site> [--syncdir <dir>] [--clean]"
                echo "Available sites: ${(k)SITE_IPS[@]}"
                return 1
                ;;
        esac
    done

    # Validate arguments
    [[ -z "$site" ]] && { echo "Error: --site argument is required"; return 1 }
    [[ -z "${SITE_IPS[$site]}" ]] && { echo "Error: Invalid site '$site'"; return 1 }
    [[ "$syncdir" != hui* ]] && { echo "Error: syncdir must be prefixed with 'hui'"; return 1 }

    # Build and execute command
    local cmd="grunt"
    $clean_flag && cmd+=" clean"
    cmd+=" debugNoHelp rsync --output.ip=\"${SITE_IPS[$site]}\" --output.dir=/Users/u229331/output/debug --output.syncdir=\"$syncdir\""
    eval "$cmd"
}

# ----------------------------------------------
# Aliases
# ----------------------------------------------

# Clear existing aliases
unalias -a

# System aliases
alias aliases='lsaliases'
alias refresh="source ~/.zshrc"

# Editor aliases
alias nano='micro'
alias zshrc="micro ~/.zshrc"

# Node version management
alias node18="nvm alias default v18.20.4 && nvm use default"
alias node20="nvm alias default v20.16.0 && nvm use default"
alias node21="nvm alias default v21.7.3 && nvm use default"

# Utilities
alias rsync="rsync -az --info=progress2"
alias npm-check-updates="ncu"
alias genlic='generate_license'

# Documentation
alias buildDocs="grunt docs --output.dir=/Users/u229331/output/docs/ --naturaldocs.bin=/Users/u229331/ND/NaturalDocs"

# Directory navigation
alias cd-feature="cd /Users/u229331/SVN/feature"
alias cd-trunk="cd /Users/u229331/SVN/trunk"
alias cd-doctor="cd /Users/u229331/GolandProjects/trane-doctor"

# Site operations
function pushDebug() {
    [[ -z "$1" ]] && {
        echo "Usage: pushDebug <site> [syncdir] [--clean]"
        echo "Available sites: ${(k)SITE_IPS[@]}"
        return 1
    }

    local site="$1"
    shift

    if [[ -n "$1" && "$1" != --* ]]; then
        helper-pushDebug --site "$site" --syncdir "$1" "${@:2}"
    else
        helper-pushDebug --site "$site" "$@"
    fi
}

# Site 1
alias site1-pushDebug='pushDebug site1'
alias site1-ssh="ssh whs74"
alias site1-pushSSH='ssh-keygen -R "[10.28.24.74]:8022" && ssh-copy-id "whs74"'
alias site1-pushRsync="scp -P 8022 ./rsync whs74:/usr/bin && scp -P 8022 ./rsyncLibs/libattr.so ./rsyncLibs/libattr.so.1 ./rsyncLibs/libattr.so.1.1.0 whs74:/usr/lib && ssh whs74 chmod u+rwx /usr/bin/rsync"

# Site 2
alias site2-pushDebug='pushDebug site2'
alias site2-ssh="ssh whs77"
alias site2-pushSSH='ssh-keygen -R "[10.28.24.77]:8022" && ssh-copy-id "whs77"'
alias site2-pushRsync="scp -P 8022 ./rsync whs77:/usr/bin && scp -P 8022 ./rsyncLibs/libattr.so ./rsyncLibs/libattr.so.1 ./rsyncLibs/libattr.so.1.1.0 whs77:/usr/lib && ssh whs77 chmod u+rwx /usr/bin/rsync"

# Site 3
alias site3-pushDebug='pushDebug site3'
alias site3-ssh="ssh whs69"
alias site3-pushSSH='ssh-keygen -R "[10.28.24.69]:8022" && ssh-copy-id "whs69"'
alias site3-pushRsync="scp -P 8022 ./rsync whs69:/usr/bin && scp -P 8022 ./rsyncLibs/libattr.so ./rsyncLibs/libattr.so.1 ./rsyncLibs/libattr.so.1.1.0 whs77:/usr/lib && ssh whs69 chmod u+rwx /usr/bin/rsync"

# ----------------------------------------------
# Final Settings
# ----------------------------------------------
unsetopt correct_all  # Disable auto-correct
