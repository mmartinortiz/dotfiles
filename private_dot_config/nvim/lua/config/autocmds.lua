-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- LazyVim's default wrap_spell autocmd only fires on FileType for "text",
-- "plaintex", "typst", "gitcommit", "markdown". Files with no recognized
-- filetype (empty string) never fire FileType, so handle them separately.
local wrap_no_filetype = vim.api.nvim_create_augroup("wrap_no_filetype", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  group = wrap_no_filetype,
  callback = function()
    if vim.bo.filetype == "" and vim.bo.buftype == "" then
      vim.opt_local.wrap = true
      vim.opt_local.spell = true
    end
  end,
})
