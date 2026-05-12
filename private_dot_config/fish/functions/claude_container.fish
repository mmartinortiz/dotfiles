function _get_node_lts_version --description "Get latest Node LTS version, default to 24 if offline"
    set -l lts_version (curl -s --connect-timeout 2 https://nodejs.org/dist/index.json | jq -r '[.[] | select(.lts != false)] | .[0].version | ltrimstr("v") | split(".")[0]' 2>/dev/null)
    if test -z "$lts_version"
        echo 24
    else
        echo "$lts_version"
    end
end

function claude_container --description "Run claude code in container with current directory only"
    # Escape argv properly
    set -l escaped_args (string escape -- $args)

    set -l magenta (set_color magenta)
    set -l cyan (set_color cyan)
    set -l yellow (set_color yellow)
    set -l dim (set_color brblack)
    set -l reset (set_color normal)

    set -l config_dir "$HOME/.claude"
    set -l config_file "$HOME/.claude.json"
    set -l skills_dir "$HOME/.agents/skills"
    set -l node_version (_get_node_lts_version)

    echo "$magenta󰧑$reset $yellow →$reset $cyan󰡨$reset Running claude in container based on $dim(Node $node_version)$reset"

    # Ensure dirs/files exist (avoid mount failure)
    test -d "$config_dir"; or mkdir -p "$config_dir"
    test -f "$config_file"; or touch "$config_file"
    test -d "$skills_dir"; or mkdir -p "$skills_dir"

    docker run --rm --interactive --tty \
        --user (id -u):(id -g) \
        --cap-drop ALL \
        --security-opt no-new-privileges \
        --env HOME=/home/node \
        --env NPM_CONFIG_PREFIX=/tmp/.npm-global \
        --env NPM_CONFIG_CACHE=/tmp/.npm-cache \
        --env PATH=/tmp/.npm-global/bin:/usr/local/bin:/usr/bin:/bin \
        --volume (pwd):/workspace \
        --volume "$config_dir":/home/node/.claude:ro \
        --volume "$config_file":/home/node/.claude.json:ro \
        --volume "$skills_dir":/home/node/.agents/skills:ro \
        --workdir /workspace \
        node:$node_version-slim \
        sh -c "npm install -g @anthropic-ai/claude-code && claude $escaped_args"
end
