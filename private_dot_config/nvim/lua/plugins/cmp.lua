local no_buffer_filetypes = {
  markdown = true,
  ["markdown.mdx"] = true,
  text = true,
  gitcommit = true,
  [""] = true, -- unrecognized/plain text files (no filetype detected)
}

return {
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = function()
          if no_buffer_filetypes[vim.bo.filetype] then
            return { "path", "snippets" }
          end
          return { "lsp", "path", "snippets", "buffer" }
        end,
        providers = {
          -- lsp/path fall back to "buffer" when they return 0 items, so the
          -- default list above isn't enough on its own: disable the buffer
          -- provider entirely for these filetypes.
          buffer = {
            enabled = function()
              return not no_buffer_filetypes[vim.bo.filetype]
            end,
          },
        },
      },
    },
  },
}
