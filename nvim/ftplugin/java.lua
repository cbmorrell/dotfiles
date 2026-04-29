-- Java LSP setup via nvim-jdtls
--
-- Why ftplugin instead of lsp-setup.lua like every other server?
-- jdtls requires a project-specific -data <workspace> flag at launch, so it
-- can't be configured once at startup. ftplugin/java.lua is sourced by Neovim
-- automatically on every Java buffer open (filetype detection), which lets
-- jdtls.start_or_attach() decide per-buffer: start a new jdtls instance for
-- this workspace, or attach to one that's already running.
local jdtls = require('jdtls')
local lsp = require('lsp-setup')  -- shared on_attach + capabilities

local root_dir = vim.fs.root(0, { '.git', 'mvnw', 'gradlew' })
if not root_dir then return end

local workspace_dir = vim.fn.stdpath('data') .. '/jdtls/workspace/' .. vim.fn.fnamemodify(root_dir, ':p:h:t')

-- Lombok support - needed to get LSP support for getters and setters
-- Download once with: curl -L https://projectlombok.org/downloads/lombok.jar -o ~/.local/share/nvim/lombok/lombok.jar
local lombok_jar = vim.fn.stdpath('data') .. '/lombok/lombok.jar'

local cmd = {
  '/Library/Java/JavaVirtualMachines/openjdk-21.jdk/Contents/Home/bin/java',
  '-Declipse.application=org.eclipse.jdt.ls.core.id1',
  '-Dosgi.bundles.defaultStartLevel=4',
  '-Declipse.product=org.eclipse.jdt.ls.core.product',
  '-Dlog.protocol=true',
  '-Dlog.level=ALL',
  '-Xms1g',
  '-jar', vim.fn.glob(vim.fn.stdpath('data') .. '/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
  '-configuration', vim.fn.stdpath('data') .. '/mason/packages/jdtls/config_mac',
  '-data', workspace_dir,
}
if vim.fn.filereadable(lombok_jar) == 1 then
  table.insert(cmd, 2, '-javaagent:' .. lombok_jar)
end

local config = {
  cmd = cmd,
  root_dir = root_dir,
  settings = {
    java = {
      configuration = {
        runtimes = {
          { name = 'JavaSE-11', path = '/Library/Java/JavaVirtualMachines/openjdk-11.jdk/Contents/Home/' },
          { name = 'JavaSE-21', path = '/Library/Java/JavaVirtualMachines/openjdk-21.jdk/Contents/Home/' },
        },
      },
    },
  },
  capabilities = lsp.capabilities,
  on_attach = function(client, bufnr)
    lsp.on_attach(client, bufnr)
    -- Note: nvim-jdtls registers :JdtUpdateConfig automatically — use that to
    -- refresh the classpath after build.gradle changes.
    -- Clear workspace cache and restart (when things are really broken)
    vim.api.nvim_buf_create_user_command(bufnr, 'JdtClearWorkspace', function()
      vim.fn.delete(workspace_dir, 'rf')
      vim.notify('jdtls workspace cleared, restarting...', vim.log.levels.INFO)
      vim.cmd('JdtRestart')
    end, { desc = 'Delete jdtls workspace cache and restart' })
  end,
}

jdtls.start_or_attach(config)

-- vim: ts=2 sts=2 sw=2 et
