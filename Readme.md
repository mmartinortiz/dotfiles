# Dotfiles

Configuration files managed with [chezmoi](https://www.chezmoi.io/). Supports two environment types: **full** (desktop with tmux, fonts, etc.) and **devcontainer** (neovim + CLI tools only).

## Prerequisites

```bash
sudo apt install fish git build-essential
```

## Installation

```bash
# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply mmartinortiz
```

During init, you will be prompted for:
- **Email** and **Name** (for git config)
- **Environment type**: `full` or `devcontainer`

## Post-install

Install brew packages and fish plugins:

```bash
brew bundle --global
fisher update
```

Or after restarting your shell, use the alias:

```bash
dotfiles-sync
```

This runs `chezmoi apply`, `brew bundle --global`, and `fisher update` in sequence.

## Fonts (full environment only)

Download and install [Nerd Fonts](https://www.nerdfonts.com/font-downloads):
- **Hack**
- **Ubuntu**

```bash
mkdir -p ~/.local/share/fonts
# For each font:
wget "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/<FontName>.zip" -P ~/.local/share/fonts
unzip ~/.local/share/fonts/<FontName>.zip -d ~/.local/share/fonts/<FontName>/
fc-cache -fv
```

## Devcontainer usage

For convinience, the variables `CHEZMOI_GIT_EMAIL` and `CHEZMOI_GIT_NAME` can be defined on your system to provide Git with an Email and Name for the `.gitconfig`. For setting up the container, create a `setup.sh` script accessible by the devcontainer with the following content:

```bash
#!/bin/bash
set -e

# Fix brew permissions
sudo chown -R "$(whoami)" /home/linuxbrew/.linuxbrew

# Dotfiles
chezmoi init --apply https://github.com/mmartinortiz/dotfiles

# Install the brew packates
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew bundle --global
```

Add the following to your `.devcontainer.json`

```json
{
  "containerEnv": {
      "CHEZMOI_ENV_TYPE": "devcontainer",
      "CHEZMOI_GIT_EMAIL": "${localEnv:CHEZMOI_GIT_EMAIL",
      "CHEZMOI_GIT_NAME": "${localEnv:CHEZMOI_GIT_NAME}"
  },
  "postCreateCommand": ".devcontainer/setup.sh"
}
```

## Fish Theme (Fish 4.3+)

The Fish shell configuration uses **Catppuccin** with automatic light/dark theme switching. Fish will automatically switch between Mocha (dark) and Latte (light) based on your terminal's color scheme.

If upgrading from an older Fish version, remove the frozen theme file to enable dynamic switching:

```bash
rm -f ~/.config/fish/conf.d/fish_frozen_theme.fish
```

Tools like `bat` and `lazygit` also switch themes automatically via the `update_theme` function.

## tmux (full environment only)

`tmux` and `fish` are not set as default shell. Call either via the terminal emulator profile or SSH command.

Start `tmux` or join an existing session:

```bash
tmux new-session -A
```

Reload `tmux` plugins with `Prefix + I`.

## Links

- [chezmoi daily operations](https://www.chezmoi.io/user-guide/daily-operations/)
- [Tmux, getting started](https://github.com/tmux/tmux/wiki/Getting-Started)
- [Awesome Tmux](https://github.com/rothgar/awesome-tmux)
- [Nerd Fonts](https://www.nerdfonts.com/)
