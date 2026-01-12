-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>cl', vim.lsp.buf.code_action, '[C]ode Action')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('<leader>y', vim.lsp.buf.hover, 'Hover Documentation')
  
  -- Open signature help in normal and insert mode
  vim.keymap.set({'n', 'i'}, '<C-y>', vim.lsp.buf.signature_help, {buffer = bufnr, desc = 'Signature Documentation'})


  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })

  -- Set underline error defaults
  vim.cmd([[highlight DiagnosticUnderlineError guifg='red']])
  vim.cmd([[highlight DiagnosticUnderlineWarn guifg='yellow']])
  vim.cmd([[highlight DiagnosticUnderlineInfo guifg='white']])
  vim.cmd([[highlight DiagnosticUnderlineHint guifg='green']])
  -- Set diagnostic configuration
  vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = true
  })
  -- Show line diagnostics in hover window (see https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#show-line-diagnostics-automatically-in-hover-window)
  vim.api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    callback = function()
      local opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = 'rounded',
        source = 'always',
        prefix = ' ',
        scope = 'cursor',
      }
      vim.diagnostic.open_float(nil, opts)
    end
  })

end

-- document existing key chains
local wk = require('which-key')
wk.add({
  { "<leader>c", group = "[C]ode" },
  { "<leader>c_", hidden = true },
  { "<leader>d", group = "[D]ocument" },
  { "<leader>d_", hidden = true },
  { "<leader>g", group = "[G]it" },
  { "<leader>g_", hidden = true },
  { "<leader>h", group = "Git [H]unk" },
  { "<leader>h_", hidden = true },
  { "<leader>r", group = "[R]ename" },
  { "<leader>r_", hidden = true },
  { "<leader>s", group = "[S]earch" },
  { "<leader>s_", hidden = true },
  { "<leader>t", group = "[T]oggle" },
  { "<leader>t_", hidden = true },
  { "<leader>w", group = "[W]orkspace" },
  { "<leader>w_", hidden = true },
  { "<leader>", group = "VISUAL <leader>", mode = "v" },
  { "<leader>h", desc = "Git [H]unk", mode = "v" },
})

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local root = vim.fs.dirname(vim.fs.find({ 'gradlew', '.git', 'mvnw' }, { upward = true })[1])
local servers = {
  -- clangd = {},
  -- gopls = {},
  pyright = {
    python = {
      analysis = {
        -- NOTE: you can pass in directories that don't exist here and it won't error, so you can just append the list of local packages from different systems and it should be fine
        extraPaths = {vim.fn.expand('~/Code/libemg')}
      }
    }
  },
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      -- diagnostics = { disable = { 'missing-fields' } },
    },
  },

  jdtls = {
    java = {
      configuration = {
        runtimes = {
          {
            name = 'JavaSE-11',
            path = '/Library/Java/JavaVirtualMachines/openjdk-11.jdk/Contents/Home/'
          },
          {
            name = 'JavaSE-21',
            path = '/Library/Java/JavaVirtualMachines/openjdk-21.jdk/Contents/Home/'
          }
        }
      }
    }
  },

  terraformls = {}

}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}


local function setup_server(server_name)
  local setup_config = {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = servers[server_name],
    filetypes = (servers[server_name] or {}).filetypes,
  }

  if server_name == 'jdtls' then
    -- jdtls requires special setup commands
    local root_dir = vim.fs.root(0, {'.git', 'mvnw', 'gradlew'})
    if not root_dir then 
      -- Skip if these commands are not available
      return
    end

    local workspace_dir = vim.fn.stdpath("data") .. "/jdtls/workspace/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

    setup_config.cmd = {
      "/Library/Java/JavaVirtualMachines/openjdk-21.jdk/Contents/Home/bin/java",
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-Xms1g",
      "-jar", vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
      "-configuration", vim.fn.stdpath("data") .. "/mason/packages/jdtls/config_mac",
      "-data", workspace_dir,
    }
    setup_config.root_dir = root_dir
  end

  vim.lsp.config(server_name, setup_config)
  vim.lsp.enable(server_name)
end

for _, server_name in ipairs(mason_lspconfig.get_installed_servers()) do
  setup_server(server_name)
end

-- vim: ts=2 sts=2 sw=2 et
