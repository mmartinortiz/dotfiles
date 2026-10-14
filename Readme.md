# Dotfiles

Configuration files managed with [chezmoi](https://www.chezmoi.io/).

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

To skip the prompts (e.g. non-interactive setup), define these environment variables:

- `CHEZMOI_GIT_EMAIL`
- `CHEZMOI_GIT_NAME`

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

## Fonts

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

## Fish Theme (Fish 4.3+)

The Fish shell configuration uses **Catppuccin** with automatic light/dark theme switching. Fish will automatically switch between Mocha (dark) and Latte (light) based on your terminal's color scheme.

If upgrading from an older Fish version, remove the frozen theme file to enable dynamic switching:

```bash
rm -f ~/.config/fish/conf.d/fish_frozen_theme.fish
```

Tools like `bat` and `lazygit` also switch themes automatically via the `update_theme` function.

## tmux

`tmux` and `fish` are not set as default shell. Call either via the terminal emulator profile or SSH command.

Start `tmux` or join an existing session:

```bash
tmux new-session -A
```

### Keybindings

**Prefix**: `C-a` (Ctrl+a)

#### Direct Bindings (no prefix)

| Key | Action |
|-----|--------|
| `C-g` | Copy mode |

#### Prefix Bindings

| Key | Action |
|-----|--------|
| `C-a` | Send prefix to nested tmux |
| `-` | Split horizontal |
| `\|` | Split vertical |
| `v` | Paste from Wayland clipboard |
| `I` | Install TPM plugins |
| `U` | Update TPM plugins |
| `Space` | Which-key menu |
| `M-g` | Lazygit popup (toggle) |
| `M-t` | Terminal popup (toggle) |

#### Which-Key Menu (prefix + Space)

| Key | Action |
|-----|--------|
| `o` | +Popups |
| `w` | +Windows |
| `P` | +Panes |
| `b` | +Buffers |
| `s` | +Sessions |
| `C` | +Client |
| `?` | +Keys |
| `r` | Reload config |

## Links

- [chezmoi daily operations](https://www.chezmoi.io/user-guide/daily-operations/)
- [Tmux, getting started](https://github.com/tmux/tmux/wiki/Getting-Started)
- [Awesome Tmux](https://github.com/rothgar/awesome-tmux)
- [Nerd Fonts](https://www.nerdfonts.com/)
