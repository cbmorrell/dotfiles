return {
  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },


  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    -- Load after startup is complete - telescope isn't needed until the user invokes it
    event = "VeryLazy",
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    config = function()
      require('telescope-setup')
    end,
  },
  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
    },
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function ()
      local harpoon = require('harpoon')
      harpoon:setup({})
    end
  },
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({
        -- netrw is disabled in init.lua; we open the tree ourselves below instead of
        -- relying on hijack_netrw, so nvim-tree never ends up as the session's sole window.
        hijack_netrw = false,
        view = {
          float = {
            enable = true,
            open_win_config = function()
              local screen_w = vim.opt.columns:get()
              local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
              local width = math.floor(screen_w * 0.5)
              local height = math.floor(screen_h * 0.7)
              return {
                relative = "editor",
                border = "rounded",
                width = width,
                height = height,
                col = math.floor((screen_w - width) / 2),
                row = math.floor((screen_h - height) / 2),
              }
            end,
          },
        },
        actions = {
          open_file = {
            -- close the floating tree once a file is picked, rather than leaving it on top
            quit_on_open = true,
          },
        },
        on_attach = function(bufnr)
          -- Embed mappings in on_attach so these mappings are only applied when attaching to the nvim-tree buffer
          local api = require "nvim-tree.api"

          local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end

          -- default mappings
          api.config.mappings.default_on_attach(bufnr)

          -- custom mappings
          vim.keymap.set("n", "<C-[>", api.tree.change_root_to_parent, opts("Up"))
          vim.keymap.del("n", "<Esc>", { buffer = bufnr})  -- unmap <Esc> to avoid accidental presses
          vim.keymap.del("n", "-", { buffer = bufnr})  -- unmap <Esc> to avoid accidental presses
          vim.keymap.set("n", "<leader>y", api.node.show_info_popup, opts("Info"))
          vim.keymap.del("n", "<C-k>", { buffer = bufnr})  -- unmap <C-k> to avoid conflict with buffer navigation
        end
      })

      -- Replace nvim-tree's hijack_netrw with our own: open a real edit window first,
      -- then open the tree in a new window beside it, so the tree is never the sole window.
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function(data)
          if vim.fn.isdirectory(data.file) ~= 1 then
            return
          end
          vim.cmd.enew()
          vim.cmd.bw(data.buf)
          vim.cmd.cd(data.file)
          require("nvim-tree.api").tree.open()
        end,
      })
    end,
}
}
