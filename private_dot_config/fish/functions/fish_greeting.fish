function fish_greeting
    if command --query fortune
        fortune --short
    end
end
