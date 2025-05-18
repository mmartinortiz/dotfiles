return {
  {
    -- A snazzy bufferline for Neovim
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      vim.keymap.set('n', '<S-TAB>', vim.cmd.bprevious, { silent = true, desc = 'previous buffer' })
      vim.keymap.set('n', '<TAB>', vim.cmd.bnext, { silent = true, desc = 'next buffer' })
    end
  },
  {
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
  },
  {
    -- Git integration for buffers
    "lewis6991/gitsigns.nvim" },
  {
    -- Library of 40+ independent Lua modules improving overall Neovim (version 0.8 and
    -- higher) experience with minimal effort
    "echasnovski/mini.nvim",
    version = "*"
  },
  {
    -- 💥 Highly experimental plugin that completely replaces the UI for messages,
    -- cmdline and the popupmenu.
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {},
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim"
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      -- "rcarriga/nvim-notify",
    }
  },
  {
    -- UI Component Library for Neovim.
    "MunifTanjim/nui.nvim" },
  {
    -- autopairs for neovim written in lua
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  },
  { "rcarriga/nvim-notify" },
  {
    -- Add/change/delete surrounding delimiter pairs with ease.
    "kylechui/nvim-surround",
    version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end
  },
  {
    -- Nvim Treesitter configurations and abstraction layer
    "nvim-treesitter/nvim-treesitter"
  },
  {
    -- Provides Nerd Font icons (glyphs) for use by neovim plugins
    "nvim-tree/nvim-web-devicons",
    opts = {}
  },
  {
    -- Status column plugin that provides a configurable 'statuscolumn' and click handlers.
    "luukvbaal/statuscol.nvim",
    config = function()
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        setopt = true,
        relculright = true,
        segments = {
          { text = { '%s' }, click = 'v:lua.ScSa' },
          {
            text = { builtin.lnumfunc, ' ' },
            condition = { true, builtin.not_empty },
            click = 'v:lua.ScLa',
          },
        },

      })
    end
  },
  {
    -- Find, Filter, Preview, Pick. All lua, all the time.
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  {
    -- A vim / nvim plugin that intelligently reopens files at your last edit position.
    "farmergreg/vim-lastplace"
  },
  {
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

  },
  {
    -- 💥 Create key bindings that stick. WhichKey helps you remember your Neovim
    -- keymaps, by showing available keybindings in a popup as you type.
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      -- File Group
      { "<leader>f",  group = "File" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>",                            desc = "Find file" },
      { "<leader>fh", "<cmd>Telescope find_files hidden=true no_ignore=true<cr>", desc = "Find file, including ignored" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",                              desc = "Open Recent file" },
      { "<leader>fn", "<cmd>enew<cr>",                                            desc = "New file" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",                             desc = "Grep files" },
      { "<leader>fH", "<cmd>Telescope live_grep hidden=true no_ignore=true<cr>",  desc = "Grep files, including ignored" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",                               desc = "Grep buffers" },
      { "<leader>ft", "<cmd>Telescope help_tags<cr>",                             desc = "Grep Help Tags" },
      { "<leader>fc", "<cmd>bd<cr>",                                              desc = "Close current buffer" },

      -- Goto group
      { "<leader>g",  group = "Goto" },
      { "<leader>gd", "<cmd>Telescope lsp_definitions<cr>",                       desc = "Goto Definition" },
      { "<leader>gI", "<cmd>Telescope lsp_implementations<cr>",                   desc = "Goto Implementation" },
      { "<leader>gr", "<cmd>Telescope lsp_references<cr>",                        desc = "Goto References" },
      { "<leader>gi", "<cmd>lua vim.diagnostic.open_float()<cr>",                 desc = "Hove Diagnostics" },
      { "<leader>gk", "<cmd>lua vim.lsp.buf.hover()<cr>",                         desc = "Hove Symbol Details" },

      -- Miscelanea
      { "<leader>m",  group = "Misc" },
      { "<leader>mc", "<cmd>Telescope commands<cr>",                              desc = "List available NeoVim commands" }

    }
  }
}
