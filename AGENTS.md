# Project Memory

## Skills

- Always load `chezmoi-config` skill when working in this repo
- Always load `caveman` skill when working in this repo

## Overview

Dotfiles managed with chezmoi. Single flat config applying to all systems equally.

## User Preferences

- Caveman mode: terse responses, no fluff, keep technical substance
- Prefers functions over abbreviations for complex shell commands (easier help, maintenance)
- Fish shell user
- Use verbose/long form arguments for fish builtins (e.g., `--global` not `-g`, `--local` not `-l`)
  - Exception: fish `test` builtin only supports short flags (`-d`, `-f`, `-n`, `-z`, etc.)
- Use verbose/long form arguments for external commands when supported (check docs first)
- NeoVim runs within TMux
- NeoVim config, when required, needs to take into account Linux and Windows systems

## Key Files

- `private_dot_config/fish/config.fish` - Main fish config (plain file, no templating)
- `private_dot_config/fish/functions/dc.fish` - Devcontainer wrapper (plain fish, no templating)
- `private_dot_config/tmux/tmux.conf.tmpl` - Tmux config
- `dot_Brewfile.tmpl` - Homebrew packages
- `.chezmoi.toml.tmpl` - Chezmoi config template

## Conventions

- Templates use `.tmpl` suffix - include `*.tmpl` in glob/grep searches
- Private files prefixed with `private_`
- Dot files prefixed with `dot_`

## Custom Functions

- `dc` - Devcontainer wrapper with subcommands: up, upf, build, exec, sh, stop, down
  - When modifying: check official devcontainer CLI docs (https://containers.dev/implementors/reference/)
  - Note: devcontainer CLI `--mount` only supports `type`, `source`, `target`, `external` - no `readonly` (use devcontainer.json for full Docker mount syntax)
- `lg` - Lazygit with dynamic Catppuccin theme (light/dark)

## Tools

- nvim, fish, starship, bat, eza, atuin, lazygit
- Catppuccin theme with auto light/dark switching
