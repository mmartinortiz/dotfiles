return {
    -- Easy Neovim-Tmux navigation, completely written in Lua
    "alexghergh/nvim-tmux-navigation",
    config = function()
        local nvim_tmux_nav = require('nvim-tmux-navigation')

        nvim_tmux_nav.setup {
            disable_when_zoomed = true -- defaults to false
        }

        vim.keymap.set('n', '<C-h>', '<Cmd>NvimTmuxNavigateLeft<CR>', {})
        vim.keymap.set('n', '<C-j>', '<Cmd>NvimTmuxNavigateDown<CR>', {})
        vim.keymap.set('n', '<C-k>', '<Cmd>NvimTmuxNavigateUp<CR>', {})
        vim.keymap.set('n', '<C-l>', '<Cmd>NvimTmuxNavigateRight<CR>', {})
    end

}
