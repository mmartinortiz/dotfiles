function opencode_container --description "Run opencode in container with current directory only"
    set --local magenta (set_color magenta)
    set --local cyan (set_color cyan)
    set --local yellow (set_color yellow)
    set --local reset (set_color normal)
    
    echo "$magenta󱜚$reset $yellow→$reset $cyan󰡨$reset Running opencode from container"
    
    set --local config_dir "$HOME/.config/opencode"
    set --local data_dir "$HOME/.local/share/opencode"
    set --local auth_file "$HOME/.local/share/opencode/auth.json"
    set --local skills_dir "$HOME/.agents/skills"
    
    # Ensure dirs/files exist (avoid mount failure)
    test -d "$config_dir"; or mkdir --parents "$config_dir"
    test -d "$data_dir"; or mkdir --parents "$data_dir"
    test -f "$auth_file"; or touch "$auth_file"
    test -d "$skills_dir"; or mkdir --parents "$skills_dir"

    docker run --rm --interactive --tty \
        --user (id --user):(id --group) \
        --cap-drop ALL \
        --security-opt no-new-privileges \
        --volume (pwd):/workspace \
        --volume "$config_dir":/home/node/.config/opencode:ro \
        --volume "$data_dir":/home/node/.local/share/opencode \
        --volume "$auth_file":/home/node/.local/share/opencode/auth.json:ro \
        --volume "$skills_dir":/home/node/.agents/skills:ro \
        --workdir /workspace \
        ghcr.io/anomalyco/opencode:latest $argv
end
