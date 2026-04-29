-- Pull in the wezterm API
local wezterm = require 'wezterm'
local helpers = require 'helpers'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Initialize key overrides map
config.keys = {}

-- This is where you actually apply your config choices
helpers.style.setup(config)
helpers.navigation.setup(config)
helpers.workspaces.setup(config, false)

-- and finally, return the configuration to wezterm
return config
