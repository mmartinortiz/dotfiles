function lg --wraps=lazygit --description "lazygit with dynamic Catppuccin theme"
    if test "$fish_terminal_color_theme" = light
        command lazygit --use-config-file="$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/themes/catppuccin/themes-mergable/latte/yellow.yml" $argv
    else
        command lazygit --use-config-file="$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/themes/catppuccin/themes-mergable/mocha/yellow.yml" $argv
    end
end
