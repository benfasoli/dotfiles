1. Clone this repo
   ```bash
   git clone https://github.com/benfasoli/dotfiles
   ```
1. Install [Homebrew](https://brew.sh)
    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```
1. Install Homebrew bundle from `Brewfile`
    ```bash
    brew bundle
    ```
1. Open terminal settings. Drag profile preference and set default.
1. Set terminal font to Fira Code Nerdfont.
1. Copy dotfile configs
    ```bash
    cp home/.vimrc ~/
    cp home/.zshrc ~/
    ```
1. Open System Preferences > Keyboard. Set repeat rate to fast. Set delay until repeat to short.
1. Open System Preferences > Trackpad. Enable tap to click.
1. Open System Preferences > Desktop & Dock. Disable recent apps.
1. [Generate SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and setup GitHub auth
