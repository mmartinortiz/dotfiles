function opencode_container --description "Run opencode in container with current directory only"
    set -l magenta (set_color magenta)
    set -l cyan (set_color cyan)
    set -l yellow (set_color yellow)
    set -l reset (set_color normal)
    
    echo "$magenta󱜚$reset $yellow→$reset $cyan󰡨$reset Running opencode from container"
    
    set -l config_dir "$HOME/.config/opencode"
    set -l data_dir "$HOME/.local/share/opencode"
    set -l skills_dir "$HOME/.agents/skills"
    
    # Ensure dirs exist (avoid mount failure)
    test -d "$config_dir"; or mkdir -p "$config_dir"
    test -d "$data_dir"; or mkdir -p "$data_dir"
    test -d "$skills_dir"; or mkdir -p "$skills_dir"

    docker run --rm --interactive --tty \
        --user (id -u):(id -g) \
        --volume (pwd):/workspace \
        --volume "$config_dir":/home/node/.config/opencode \
        --volume "$data_dir":/home/node/.local/share/opencode \
        --volume "$skills_dir":/home/node/.agents/skills \
        --workdir /workspace \
        ghcr.io/anomalyco/opencode:latest $argv
end
