return {
    -- A snazzy bufferline for Neovim
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        vim.keymap.set('n', '<S-TAB>', vim.cmd.bprevious, { silent = true, desc = 'previous buffer' })
        vim.keymap.set('n', '<TAB>', vim.cmd.bnext, { silent = true, desc = 'next buffer' })
    end
}
