# Plugin bass
set -l plugin_dir /nix/store/rmx1z3940a5bjw35arfpz31x27ls77p2-source

# Set paths to import plugin components
if test -d $plugin_dir/functions
    set fish_function_path $fish_function_path[1] $plugin_dir/functions $fish_function_path[2..-1]
end

if test -d $plugin_dir/completions
    set fish_complete_path $fish_complete_path[1] $plugin_dir/completions $fish_complete_path[2..-1]
end

# Source initialization code if it exists.
if test -d $plugin_dir/conf.d
    for f in $plugin_dir/conf.d/*.fish
        source $f
    end
end

if test -f $plugin_dir/key_bindings.fish
    source $plugin_dir/key_bindings.fish
end

if test -f $plugin_dir/init.fish
    source $plugin_dir/init.fish
end
