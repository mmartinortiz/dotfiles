function _get_stable_node_lts --description "Get Node LTS version at least 7 days old, default to 24 if offline"
    set --local cutoff (date --date='7 days ago' +%Y-%m-%d)

    # Get version and date at least 7 days old
    set --local result (curl --silent --connect-timeout 2 https://nodejs.org/dist/index.json | jq --raw-output --arg cutoff "$cutoff" '
        [.[] | select(.lts != false and .date <= $cutoff)] | .[0] | "\(.version)|\(.date)"
    ' 2>/dev/null)

    if test -z "$result"
        echo "v24|"
    else
        echo "$result"
    end
end

function claude_container --description "Run claude code in container with current directory only"
    set --local magenta (set_color magenta)
    set --local cyan (set_color cyan)
    set --local yellow (set_color yellow)
    set --local dim (set_color brblack)
    set --local reset (set_color normal)

    set --local config_dir "$HOME/.claude"
    set --local settings_file "$config_dir/settings.json"
    set --local claude_md_file "$config_dir/CLAUDE.md"
    set --local config_file "$HOME/.claude.json"
    set --local skills_dir "$HOME/.agents/skills"

    set --local node_info (string split '|' (_get_stable_node_lts))
    set --local node_version $node_info[1]
    set --local node_date $node_info[2]

    # Strip 'v' prefix for docker tag
    set --local node_tag (string replace 'v' '' $node_version)

    # Escape argv for sh -c
    set --local escaped_args (string escape -- $argv)

    echo "$magenta󰧑$reset $yellow→$reset $cyan󰡨$reset Running claude in container $dim(Node $node_version, $node_date)$reset"

    # Ensure dirs/files exist (avoid mount failure)
    test -d "$config_dir"; or mkdir --parents "$config_dir"
    test -f "$settings_file"; or touch "$settings_file"
    test -f "$claude_md_file"; or touch "$claude_md_file"
    test -f "$config_file"; or touch "$config_file"
    test -d "$skills_dir"; or mkdir --parents "$skills_dir"

    docker run --rm --interactive --tty \
        --user (id --user):(id --group) \
        --cap-drop ALL \
        --security-opt no-new-privileges \
        --env HOME=/home/node \
        --env NPM_CONFIG_PREFIX=/tmp/.npm-global \
        --env NPM_CONFIG_CACHE=/tmp/.npm-cache \
        --env PATH=/tmp/.npm-global/bin:/usr/local/bin:/usr/bin:/bin \
        --volume (pwd):/workspace \
        --volume "$config_dir":/home/node/.claude \
        --volume "$settings_file":/home/node/.claude/settings.json:ro \
        --volume "$claude_md_file":/home/node/.claude/CLAUDE.md:ro \
        --volume "$config_file":/home/node/.claude.json \
        --volume "$skills_dir":/home/node/.agents/skills:ro \
        --workdir /workspace \
        node:$node_tag-slim \
        sh -c "npm install --global @anthropic-ai/claude-code && exec claude $escaped_args"
end
