# Dotfiles

Managed with `chezmoi`. Installing `chezmoi` and the dotfiles on a new machines with a single command:


```bash
# bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply mmartinortiz
```

```fish
# fish
curl -fsLS get.chezmoi.io | sh -s -- init --apply mmartinortiz
```

[Reference](https://www.chezmoi.io/user-guide/daily-operations/#automatically-commit-and-push-changes-to-your-repo)

`tmux` and `fish`  are installed but not set as default starting point. It is up to the user to call either `fish` or `tmux` via the profile on the term emulator or the SSH command.

Start `tmux` or join an existing session:

```bash
tmux new-session -A
```

## Links

- [Tmux, getting started](https://github.com/tmux/tmux/wiki/Getting-Started)
- [Awesome Tmux](https://github.com/rothgar/awesome-tmux)

Reload `tmux` plugins with `Prefix + I`.

