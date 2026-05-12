function fish_greeting
    if command -q fortune
        fortune -s
    end
end
