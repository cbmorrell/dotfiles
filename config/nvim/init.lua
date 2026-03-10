-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '


vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  -- Automatically converts filetypes of this pattern to "terraform" filetype so terraform LSP is applied
  pattern = { "*.tf", "*.tfvars", "*.hcl" },
  callback = function()
    vim.bo.filetype = "terraform"
  end,
})


-- [[ Install `lazy.nvim` plugin manager ]]
require 'lazy-bootstrap'

-- [[ Configure plugins ]]
-- This will call setup for LazyVim on all lua files in lua/plugins/. It merges all the tables in those files into one table and installs all the plugins.
-- For more info see https://github.com/folke/lazy.nvim#-structuring-your-plugins
require("lazy").setup("plugins")

-- [[ Setting options ]]
require 'options'

-- [[ Basic Keymaps ]]
require 'keymaps'

-- NOTE: telescope-setup, lsp-setup, and cmp-setup are intentionally not required here.
-- They are loaded lazily via the config() function of their respective plugins in lua/plugins/,
-- so they only run once those plugins are loaded (on VeryLazy / BufReadPre).

-- [[ Configure Treesitter ]]
-- (syntax parser for highlighting)
require 'treesitter-setup'

-- Import custom commands
require 'commands'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
