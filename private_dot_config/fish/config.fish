# Abbreviations
abbr --add -- ga 'git add'
abbr --add -- gc 'git commit -m'
abbr --add -- gp 'git push'
abbr --add -- cm chezmoi

# Aliases
alias cat 'bat --plain'
alias eza 'eza --icons auto --git --hyperlink --group-directories-first --header'
alias grep batgrep
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

# If a variable is declared Universal, the variable is immediately available
# to all the user's Fish instances in the machine. These variables are kept
# under the file ~/.config/fish/fish_variables (not tracked by chezmoi)

# A Global variable is available to all the functions running in the same
# shell where they were declared, but not accessible to programs started
# from that shell, for that the variables need to be exported.

# Interactive shell initialisation
# Customize "pure" colors and options
set -g pure_color_current_directory brcyan
set -g pure_color_mute yellow

set --universal pure_symbol_virtualenv_prefix "" # 🐍
set --universal pure_color_virtualenv green

if test -f ~/.local/bin
    fish_add_path ~/.local/bin
end

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

set --universal --export SHELL /usr/bin/fish
set --universal --export EDITOR nvim
set --universal --export BATDIFF_USE_DELTA true

# Ripgrep
set --universal --export RIPGREP_CONFIG_PATH ~/.config/ripgrep/ripgrep.cfg
if command -q rg
    rg --generate complete-fish >~/.config/fish/completions/rg.fish
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

if test (which tmux 2> /dev/null)
    status is-interactive; and begin
        set fish_tmux_config $HOME/.config/tmux/tmux.conf
        set fish_tmux_default_session_name zero
        set fish_tmux_autostart true
        set fish_tmux_autoquit true
    end
end
