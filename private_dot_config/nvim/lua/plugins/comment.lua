return {
    -- 🧠 💪 // Smart and powerful comment plugin for neovim. Supports treesitter,
    -- dot repeat, left-right/up-down motions, hooks, and more
    "numToStr/Comment.nvim",
    opts = {
        ---Add a space b/w comment and the line
        ---@type boolean
        padding = true,

        ---Lines to be ignored while comment/uncomment.
        ---Could be a regex string or a function that returns a regex string.
        ---Example: Use '^$' to ignore empty lines
        ---@type string|function
        ignore = nil,

        ---Create basic (operator-pending) and extended mappings for NORMAL + VISUAL mode
        ---@type table
        mappings = {
            ---operator-pending mapping
            ---Includes `gcc`, `gcb`, `gc[count]{motion}` and `gb[count]{motion}`
            basic = true,
            ---extra mapping
            ---Includes `gco`, `gcO`, `gcA`
            extra = true,
            ---extended mapping
            ---Includes `g>`, `g<`, `g>[count]{motion}` and `g<[count]{motion}`
            extended = false,
        },

        ---LHS of toggle mapping in NORMAL + VISUAL mode
        ---@type table
        toggler = {
            ---line-comment keymap
            -- line = 'gcc',
            line = '<leader>/',
            ---block-comment keymap
            block = 'gbc',
            -- block = '<leader>/',
        },

        ---LHS of operator-pending mapping in NORMAL + VISUAL mode
        ---@type table
        opleader = {
            ---line-comment keymap
            -- line = 'gc',
            line = '<leader>/',
            ---block-comment keymap
            block = 'gb',
        },
    }
}
