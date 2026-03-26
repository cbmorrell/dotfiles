local active = "rose-pine"

local themes = {
  { "Mofiqul/vscode.nvim", colorscheme = "vscode" },
  { "navarasu/onedark.nvim", colorscheme = "onedark" },
  { "AlexvZyl/nordic.nvim", colorscheme = "nordic" },
  { "scottmckendry/cyberdream.nvim", colorscheme = "cyberdream" },
  { "catppuccin/nvim", name = "catppuccin", colorscheme = "catppuccin" },
  { "rebelot/kanagawa.nvim", colorscheme = "kanagawa" },
  { "nyoom-engineering/oxocarbon.nvim", colorscheme = "oxocarbon" },
  { "JoosepAlviste/palenightfall.nvim", colorscheme = "palenightfall" },
  { "rose-pine/neovim", name = "rose-pine", colorscheme = "rose-pine", opts = { variant = "main", styles = { italic = false } } },
  { "aktersnurra/no-clown-fiesta.nvim", name = "no-clown-fiesta", colorscheme = "no-clown-fiesta" },
  { "projekt0n/github-nvim-theme", colorscheme = "github_dark" },
  { "vague-theme/vague.nvim", colorscheme = "vague" },
  { "smit4k/shale.nvim", colorscheme = "shale" }
}

-- Build lazy.nvim plugin specs from the themes table.
-- Only the active theme loads at startup; the rest are deferred.
local specs = {}
for _, theme in ipairs(themes) do
  local is_active = theme.colorscheme == active
  local path = theme[1]
  local spec = {
    path,
    lazy = not is_active,
    -- higher priority ensures the theme loads before other plugins
    priority = is_active and 1000 or nil,
  }

  -- some plugins register under a different name (e.g. "catppuccin" not "catppuccin/nvim")
  if theme.name then spec.name = theme.name end

  -- apply the colorscheme once the active plugin has loaded
  if is_active then
    local opts = theme.opts
    local name = theme.name
    spec.config = function()
      if opts and name then
        require(name).setup(opts)
      end
      vim.cmd.colorscheme(active)
    end
  end

  table.insert(specs, spec)
end

return specs
