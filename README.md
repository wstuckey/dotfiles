# Dotfiles

Automated setup script for a development environment on macOS and Linux.

## Quick Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/wstuckey/dotfiles/main/setup.sh)"
```

## What Gets Installed

| Tool | Description |
|------|-------------|
| **Zsh** | Shell |
| **Oh My Zsh** | Zsh framework with plugins |
| **Git** | Version control |
| **Python + pipx** | Python and isolated package manager |
| **thefuck** | Command correction |
| **OpenJDK 17** | Java runtime |
| **Neovim** | Text editor (with full IDE config) |
| **ripgrep + fd** | Fast search tools (for Telescope) |
| **NVM + Node.js** | Node version manager with LTS |

## Repository Structure

```
dotfiles/
├── setup.sh              # Main installation script
├── .zshrc                # Zsh configuration
├── .zshrc.work           # Work-specific config (optional)
├── .gitignore            # Excludes SSH private keys
├── ssh/
│   ├── config            # SSH config (symlinked to ~/.ssh/config)
│   ├── id_personal       # Your personal SSH key (not committed)
│   ├── id_personal.pub
│   ├── id_work           # Your work SSH key (not committed)
│   └── id_work.pub
└── nvim/                 # Neovim configuration (symlinked to ~/.config/nvim)
    ├── init.lua
    ├── lazy-lock.json    # Plugin version lock file
    └── lua/
        ├── config/       # Core configuration
        └── plugins/      # Plugin configurations
```

## SSH Key Setup

The setup script manages your SSH keys. Before running setup on a new machine:

### First-time Setup

1. Run the setup script
2. When prompted, copy your SSH keys to `~/dotfiles/ssh/`:

```bash
cp ~/.ssh/id_personal ~/dotfiles/ssh/
cp ~/.ssh/id_personal.pub ~/dotfiles/ssh/
cp ~/.ssh/id_work ~/dotfiles/ssh/
cp ~/.ssh/id_work.pub ~/dotfiles/ssh/
```

3. Press Enter to continue

The script will:
- Copy keys to `~/.ssh/` with correct permissions (600 for private, 644 for public)
- Symlink `ssh/config` to `~/.ssh/config`
- Add keys to the SSH agent

### Moving to a New Machine

1. Clone dotfiles: `git clone https://github.com/wstuckey/dotfiles.git ~/dotfiles`
2. Copy your SSH keys to `~/dotfiles/ssh/` (via USB, secure transfer, etc.)
3. Run `./setup.sh`

**Note:** Private keys (`id_personal`, `id_work`) are in `.gitignore` and will never be committed.

## Post-Install

After installation:

1. Restart your terminal or run `exec zsh`
2. Verify SSH keys: `ssh-add -l`
3. Test connections:
   ```bash
   ssh -T git@github.com
   ssh -T git@git.ein-softworks.com
   ```

## Customization

The `.zshrc` automatically sources these files if they exist:

- `~/.zshrc.work` — Work-specific configuration
- `~/.zshrc.local` — Machine-specific overrides

This keeps the main config clean while allowing customization.

## Manual Installation

If you prefer to install manually:

```bash
# Clone the repo
git clone https://github.com/wstuckey/dotfiles.git ~/dotfiles

# Symlink .zshrc
ln -sf ~/dotfiles/.zshrc ~/.zshrc

# Set up SSH
mkdir -p ~/.ssh && chmod 700 ~/.ssh
ln -sf ~/dotfiles/ssh/config ~/.ssh/config
cp ~/dotfiles/ssh/id_* ~/.ssh/
chmod 600 ~/.ssh/id_personal ~/.ssh/id_work
chmod 644 ~/.ssh/id_personal.pub ~/.ssh/id_work.pub

# Set up Neovim config
mkdir -p ~/.config
ln -sf ~/dotfiles/nvim ~/.config/nvim

# Install Neovim plugins
nvim --headless "+Lazy! sync" +qa

# (Optional) Copy work config
cp ~/dotfiles/.zshrc.work ~/.zshrc.work

# Reload
source ~/.zshrc
```

## Updating

```bash
cd ~/dotfiles
git pull
source ~/.zshrc
```
