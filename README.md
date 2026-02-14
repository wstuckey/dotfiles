# Dotfiles

Automated setup script for a development environment on macOS and Linux.

## Quick Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/wstuckey/dotfiles/main/setup.sh)"
```

## What Gets Installed

| Tool              | Description                            |
| ----------------- | -------------------------------------- | --- |
| **Zsh**           | Shell                                  |
| **Oh My Zsh**     | Zsh framework with plugins             |
| **Git**           | Version control                        |
| **Python + pipx** | Python and isolated package manager    |
| **OpenJDK 17**    | Java runtime                           |
| **ripgrep + fd**  | Fast search tools (for Telescope)      | f   |
| **eza**           | Modern replacement for `ls` and `tree` |
| **zoxide**        | Smarter `cd` that learns your habits   |
| **tmux**          | Terminal multiplexer                   |
| **NVM + Node.js** | Node version manager with LTS          |

## Repository Structure

```
dotfiles/
├── setup.sh              # Main installation script
├── .zshrc                # Zsh configuration
├── .zshrc.work           # Work-specific config (optional)
├── .gitignore            # Excludes SSH private keys
└── ssh/
    ├── config            # SSH config (symlinked to ~/.ssh/config)
    ├── id_personal       # Your personal SSH key (not committed)
    ├── id_personal.pub
    ├── id_work           # Your work SSH key (not committed)
    └── id_work.pub
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
2. **Set your terminal font to "JetBrainsMono Nerd Font"** (required for icons)
3. Verify SSH keys: `ssh-add -l`
4. Test connections:
   ```bash
   ssh -T git@github.com
   ssh -T git@git.ein-softworks.com
   ```

## Customization

The setup script will ask: **"Is this a work machine?"**

- **Yes** → Symlinks `.zshrc.work` for work-specific aliases (sites, pushDebug, etc.)
- **No** → Only the main `.zshrc` is used

You can also manually enable/disable work config:

```bash
# Enable work config
ln -sf ~/dotfiles/.zshrc.work ~/.zshrc.work

# Disable work config
rm ~/.zshrc.work
```

Additional local overrides can go in `~/.zshrc.local` (not tracked in git).

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

## Helpful Commands

After setup, these commands are available:

| Command           | Description                             |
| ----------------- | --------------------------------------- |
| `aliases`         | Show all available aliases              |
| `lsaliases`       | Show work-specific aliases (if enabled) |
| `tmux-help`       | Show tmux cheatsheet                    |
| `z <path>`        | Smart cd (zoxide)                       |
| `zi`              | Interactive directory picker            |
| `ll`              | List files with details (eza)           |
| `lt`              | Tree view (eza)                         |
| `dotfiles`        | cd to ~/dotfiles                        |
| `dotfiles-update` | Pull latest and refresh                 |
| `refresh`         | Reload .zshrc                           |
