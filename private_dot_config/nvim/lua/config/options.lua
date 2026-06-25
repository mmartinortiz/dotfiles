-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Enable format-on-save globally (LazyVim + conform.nvim)
vim.g.autoformat = true
--
-- LSP Server to use for Python.
-- Set to "basedpyright" to use basedpyright instead of pyright.
vim.g.lazyvim_python_lsp = "pyright"
-- Set to "ruff_lsp" to use the old LSP implementation version.
vim.g.lazyvim_python_ruff = "ruff"
-- Use fish as shell
vim.o.shell = "fish"

-- Clipboard configuration
-- Use system clipboard for all yank/paste operations
vim.opt.clipboard = "unnamedplus"

if vim.fn.has("win32") == 1 or vim.fn.has("wsl") == 1 then
  -- Windows/WSL: use win32yank for system clipboard
  vim.g.clipboard = {
    name = "win32yank",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }
elseif vim.env.WAYLAND_DISPLAY then
  -- Wayland: use wl-clipboard directly
  vim.g.clipboard = {
    name = "wl-clipboard",
    copy = {
      ["+"] = "wl-copy --type text/plain",
      ["*"] = "wl-copy --primary --type text/plain",
    },
    paste = {
      ["+"] = function()
        return vim.fn.systemlist("wl-paste --no-newline")
      end,
      ["*"] = function()
        return vim.fn.systemlist("wl-paste --no-newline --primary")
      end,
    },
    cache_enabled = 0,
  }
elseif vim.env.DISPLAY then
  -- X11: use xclip directly
  vim.g.clipboard = {
    name = "xclip",
    copy = {
      ["+"] = "xclip -quiet -in -selection clipboard",
      ["*"] = "xclip -quiet -in -selection primary",
    },
    paste = {
      ["+"] = "xclip -out -selection clipboard",
      ["*"] = "xclip -out -selection primary",
    },
    cache_enabled = 0,
  }
elseif vim.env.TMUX then
  -- Remote/SSH in tmux (no display server): dual-write OSC52 + tmux buffer
  -- Copy: OSC52 sends to host terminal clipboard, tmux load-buffer for inter-pane p
  -- Paste: tmux save-buffer (OSC52 paste unsupported by most terminals)
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "tmux+osc52",
    copy = {
      ["+"] = function(lines)
        osc52.copy("+")(lines)
        local content = table.concat(lines, "\n")
        vim.fn.system({ "tmux", "load-buffer", "-" }, content)
      end,
      ["*"] = function(lines)
        osc52.copy("*")(lines)
        local content = table.concat(lines, "\n")
        vim.fn.system({ "tmux", "load-buffer", "-" }, content)
      end,
    },
    paste = {
      ["+"] = function()
        return vim.fn.systemlist({ "tmux", "save-buffer", "-" })
      end,
      ["*"] = function()
        return vim.fn.systemlist({ "tmux", "save-buffer", "-" })
      end,
    },
    cache_enabled = 0,
  }
else
  -- Fallback for other environments: OSC52
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
end
