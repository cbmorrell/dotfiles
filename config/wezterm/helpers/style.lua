local wezterm = require 'wezterm'

local module = {}

function module.setup(config)
  -- For example, changing the color scheme:
  config.color_scheme = "Vs Code Dark+ (Gogh)"

  -- Use default hyperlink rules
  config.hyperlink_rules = wezterm.default_hyperlink_rules()

  -- Adjust default window size
  config.initial_rows = 18
  config.initial_cols = 100

  -- Set FPS limit
  config.max_fps = 240

  -- Ligatures conver != to special glyphs - disable this
  config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
end

return module
