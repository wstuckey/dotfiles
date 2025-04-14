#!/bin/bash

# Install Zsh and Git
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  sudo apt update && sudo apt install -y zsh git
elif [[ "$OSTYPE" == "darwin"* ]]; then
  brew install zsh git
fi

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -y

# Clone dotfiles and symlink .zshrc
git clone https://github.com/wstuckey/dotfiles.git ~/dotfiles
ln -sf ~/dotfiles/.zshrc ~/.zshrc

# Change shell to Zsh (if not already)
chsh -s $(which zsh)

echo "Done! Restart your terminal."
