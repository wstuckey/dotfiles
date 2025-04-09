This is a script to automatically install zsh, git, oh-my-zsh, and my config file on an linux/mac shell with one command. 

Simply type:

`bash -c "$(curl -fsSL https://wstuckey.github.io/dotfiles/setup.sh)"`

Note: GitHub Pages adds HTML headers by default, which can break script execution. To fix, use raw.githack.com to proxy the file without headers:

`bash -c "$(curl -fsSL https://raw.githack.com/wstuckey/wstuckey.github.io/dotfiles/setup.sh)"`
