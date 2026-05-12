function _get_stable_node_lts --description "Get Node LTS version at least 7 days old, default to 24 if offline"
    set -l cutoff (date -d '7 days ago' +%Y-%m-%d)

    # Get version and date at least 7 days old
    set -l result (curl -s --connect-timeout 2 https://nodejs.org/dist/index.json | jq -r --arg cutoff "$cutoff" '
        [.[] | select(.lts != false and .date <= $cutoff)] | .[0] | "\(.version)|\(.date)"
    ' 2>/dev/null)

    if test -z "$result"
        echo "v24|"
    else
        echo "$result"
    end
end

function claude_container --description "Run claude code in container with current directory only"
    set -l magenta (set_color magenta)
    set -l cyan (set_color cyan)
    set -l yellow (set_color yellow)
    set -l dim (set_color brblack)
    set -l reset (set_color normal)

    set -l config_dir "$HOME/.claude"
    set -l sessions_dir "$HOME/.claude/sessions"
    set -l backups_dir "$HOME/.claude/backups"
    set -l history_file "$HOME/.claude/history.jsonl"
    set -l projects_dir "$HOME/.claude/projects"
    set -l config_file "$HOME/.claude.json"
    set -l skills_dir "$HOME/.agents/skills"

    set -l node_info (string split '|' (_get_stable_node_lts))
    set -l node_version $node_info[1]
    set -l node_date $node_info[2]

    # Strip 'v' prefix for docker tag
    set -l node_tag (string replace 'v' '' $node_version)

    # Escape argv for sh -c
    set -l escaped_args (string escape -- $argv)

    echo "$magenta󰧑$reset $yellow→$reset $cyan󰡨$reset Running claude in container $dim(Node $node_version, $node_date)$reset"

    # Ensure dirs/files exist (avoid mount failure)
    test -d "$config_dir"; or mkdir -p "$config_dir"
    test -d "$sessions_dir"; or mkdir -p "$sessions_dir"
    test -d "$backups_dir"; or mkdir -p "$backups_dir"
    test -d "$history_file"; or touch "$history_file"
    test -d "$projects_dir"; or mkdir -p "$projects_dir"
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
        --volume "$sessions_dir":/home/node/.claude/sessions \
        --volume "$backups_dir":/home/node/.claude/backups \
        --volume "$history_file":/home/node/.claude/history.jsonl \
        --volume "$projects_dir":/home/node/.claude/projects \
        --volume "$config_file":/home/node/.claude.json \
        --volume "$skills_dir":/home/node/.agents/skills:ro \
        --workdir /workspace \
        node:$node_tag-slim \
        sh -c "npm install -g @anthropic-ai/claude-code && exec claude $escaped_args"
end
