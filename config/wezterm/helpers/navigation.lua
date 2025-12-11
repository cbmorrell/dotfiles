local wezterm = require 'wezterm'
local act = wezterm.action

local module = {}

function module.setup(config)
  -- Whether or not to unzoom pane when a direction key is pressed
  config.unzoom_on_switch_pane = true

  -- Remap keys
  config.keys = {
    -- See ASCII table for combined characters to determine which hex value to send (see https://www.physics.udel.edu/~watson/scen103/ascii.html)
    -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word (see https://github.com/wez/wezterm/issues/253)
    {key="LeftArrow", mods="OPT", action=act{SendString="\x1bb"}},
    -- Make Option-Right equivalent to Alt-f; forward-word
    {key="RightArrow", mods="OPT", action=act{SendString="\x1bf"}},
    -- Make Cmd-Left equivalent to Ctrl-a (start of line)
    {key="LeftArrow", mods="CMD", action=act{SendString="\x01"}},
    -- Make Cmd-Right equivalent to Ctrl-e (end of line)
    {key="RightArrow", mods="CMD", action=act{SendString="\x05"}},
    -- Make Cmd-Backspace equivalent to Ctrl-u (delete line)
    {key="Backspace", mods="CMD", action=act{SendString="\x15"}},
    -- Set zoom of pane
    {key="i", mods="CMD|SHIFT", action=act.TogglePaneZoomState},
    -- Set directions for pane navigation
    {key="h", mods="CMD|SHIFT", action=act.ActivatePaneDirection "Left"},
    {key="j", mods="CMD|SHIFT", action=act.ActivatePaneDirection "Up"},
    {key="k", mods="CMD|SHIFT", action=act.ActivatePaneDirection "Down"},
    {key="l", mods="CMD|SHIFT", action=act.ActivatePaneDirection "Right"},
    {key="t", mods="CMD|SHIFT", action=act.SplitPane{direction='Right', size={Percent=30}}}
  }
end

return module
