return {
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        per_filetype = {
          markdown = { "path", "snippets" },
          ["markdown.mdx"] = { "path", "snippets" },
          text = { "path", "snippets" },
          gitcommit = { "path", "snippets" },
        },
      },
    },
  },
}
