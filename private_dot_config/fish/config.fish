# Abbreviations
abbr --add -- ga 'git add'
abbr --add -- gc 'git commit -m'
abbr --add -- gp 'git push'
abbr --add -- cm 'chezmoi'

# Aliases
alias cat 'bat --plain'
alias eza 'eza --icons auto --git --hyperlink --group-directories-first --header'
alias grep 'batgrep'
alias ip 'ip --color --brief'
alias la 'eza -a'
alias less 'bat --paging=always'
alias lg lazygit
alias ll 'eza -l'
alias lla 'eza -la'
alias ls eza
alias lt 'eza --tree'
alias lta 'eza --tree --all'
alias man batman
alias more 'bat --paging=always'
alias tree 'exa --tree --group-directories-first'
alias v nvim
alias vi nvim
alias vim nvim
alias vimdiff 'nvim -d'

# Variables in Fish can be "exported". It means that they will be inherited
# by any command started by the Fish shell. Exporting is necessary for
# variables that need to be used by other programs, like could be $LESS.
# By default, variables are not exported.

# Interactive shell initialisation
# Customize "pure" colors and options
set -g pure_color_current_directory brcyan
set -g pure_color_mute yellow

set --universal pure_symbol_virtualenv_prefix "" # 🐍
set --universal pure_color_virtualenv green

fish_add_path ~/.local/bin
if test -d ~/bin
	fish_add_path ~/bin
end

# Enable VI key bindings
if test -n "$TERM"
	fish_vi_key_bindings
	set -g fish_cursor_default block blink
	set -g fish_cursor_insert line blink
	set -g fish_cursor_replace_one underscore blink
	set -g fish_cursor_visual block
end

# Sponge plugin config
set sponge_delay 5

# Ayu Mirage theme. Dumped with
# fish_config theme dump "ayu Mirage" > ayu_mirage.fish
set -g fish_color_autosuggestion 6c7086
set -g fish_color_cancel f38ba8
set -g fish_color_command 89b4fa
set -g fish_color_comment 7f849c
set -g fish_color_cwd f9e2af
set -g fish_color_cwd_root red
set -g fish_color_end fab387
set -g fish_color_error f38ba8
set -g fish_color_escape eba0ac
set -g fish_color_gray 6c7086
set -g fish_color_history_current --bold
set -g fish_color_host 89b4fa
set -g fish_color_host_remote a6e3a1
set -g fish_color_keyword f38ba8
set -g fish_color_match F07171
set -g fish_color_normal cdd6f4
set -g fish_color_operator f5c2e7
set -g fish_color_option a6e3a1
set -g fish_color_param f2cdcd
set -g fish_color_quote a6e3a1
set -g fish_color_redirection f5c2e7
set -g fish_color_search_match --background=313244
set -g fish_color_selection --background=313244
set -g fish_color_status f38ba8
set -g fish_color_user 94e2d5
set -g fish_color_valid_path --underline
set -g fish_pager_color_background
set -g fish_pager_color_completion cdd6f4
set -g fish_pager_color_description 6c7086
set -g fish_pager_color_prefix f5c2e7
set -g fish_pager_color_progress 6c7086
set -g fish_pager_color_secondary_background
set -g fish_pager_color_secondary_completion
set -g fish_pager_color_secondary_description
set -g fish_pager_color_secondary_prefix
set -g fish_pager_color_selected_background
set -g fish_pager_color_selected_completion
set -g fish_pager_color_selected_description
set -g fish_pager_color_selected_prefix

set --global --export SHELL /usr/bin/fish
set --global --export EDITOR nvim
set --global --export BATDIFF_USE_DELTA true

# Ripgrep
set --global --export RIPGREP_CONFIG_PATH ~/.config/ripgrep/ripgrep.cfg 
if command -q rg
  rg --generate complete-fish > ~/.config/fish/completions/rg.fish
end

if test "$TERM" != dumb
	/home/linuxbrew/.linuxbrew/bin/starship init fish | source
end

eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)

batman --export-env | source
eval (batpipe)

# Include completions provided by brew
if test -d (brew --prefix)/share/fish/completions
    set --prepend fish_complete_path (brew --prefix)/share/fish/completions
end
if test -d (brew --prefix)/share/fish/vendor_completions.d
    set --prepend fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
end

tmux new-session -A -s zero

