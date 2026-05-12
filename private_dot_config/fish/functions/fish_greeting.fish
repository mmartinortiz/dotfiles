function fish_greeting
    if command --query fortune
        fortune -s
    end
end
