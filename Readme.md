# Dotfiles

Managed with `chezmoi`

- [Tmux, getting started](https://github.com/tmux/tmux/wiki/Getting-Started)

## Install chezmoi and your dotfiles on a new machine with a single command

```bash
# bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply mmartinortiz
```

```fish
# fish
curl -fsLS get.chezmoi.io | sh -s -- init --apply mmartinortiz
```

[Reference](https://www.chezmoi.io/user-guide/daily-operations/#automatically-commit-and-push-changes-to-your-repo)

