return {
  {
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'onedark'
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },
  {
    "rebelot/kanagawa.nvim",
    priority = 1000
  },
  {
    'nyoom-engineering/oxocarbon.nvim',
    priority = 1000
  },
  {
    'AlexvZyl/nordic.nvim',
    lazy = false,
    priority = 1000,
    config = function()
        require 'nordic' .load()
    end
  },
  {
    'JoosepAlviste/palenightfall.nvim',
    priority = false
  },
  {
    'rose-pine/neovim',
    name = 'rose-pine'
  },
  {
    'aktersnurra/no-clown-fiesta.nvim',
    name = 'no-clown-fiesta'
  },
  {
    'projekt0n/github-nvim-theme'
  },
  {
    'Mofiqul/vscode.nvim'
  },
  {
    "vague-theme/vague.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other plugins
    config = function()
      -- NOTE: you do not need to call setup if you don't want to.
      require("vague").setup({
        -- optional configuration here
      })
      vim.cmd("colorscheme vague")
    end
  },
  {
      "scottmckendry/cyberdream.nvim",
      lazy = false,
      priority = 1000,
  }
}
