local wezterm = require 'wezterm'
local act = wezterm.action
local tables = require 'helpers.tables'

local module = {}

function module.setup(config)
  -- Whether or not to unzoom pane when a direction key is pressed
  config.unzoom_on_switch_pane = true

  -- Remap keys
  local navigation_keys = {
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
    {key="j", mods="CMD|SHIFT", action=act.ActivatePaneDirection "Down"},
    {key="k", mods="CMD|SHIFT", action=act.ActivatePaneDirection "Up"},
    {key="l", mods="CMD|SHIFT", action=act.ActivatePaneDirection "Right"},
    -- Creates a small pane (typically used as a terminal pane)
    {key="t", mods="CMD|SHIFT", action=act.SplitPane{direction="Right", size={Percent=30}}},
    -- Send Shift+Enter as escape sequence for Claude Code multiline input
    {key="Enter", mods="SHIFT", action=act{SendString="\x1b[13;2u"}},
    -- Rename the current window (empty input clears the custom name) - this can also be done via the CLI
    {key="n", mods="CMD|SHIFT", action=wezterm.action_callback(function(window, pane)
      window:perform_action(
        act.PromptInputLine {
          description = wezterm.format {
            {Attribute={Intensity='Bold'}},
            {Foreground={AnsiColor='Fuchsia'}},
            {Text='Enter name for window'},
          },
          action = wezterm.action_callback(function(inner_window, inner_pane, line)
            if line == nil then return end
            inner_window:mux_window():set_title(line)
          end),
        },
        pane
      )
    end)},
  }

  tables.extend_table(config.keys, navigation_keys)

  wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
    -- Default behaviour is to show the pane title, so we override it here
    local title = wezterm.mux.get_window(tab.window_id):get_title()
    if title == '' then
      title = tab.active_pane.title
    end

    local zoomed = tab.active_pane.is_zoomed and '[Z] ' or ''
    local index = #tabs > 1 and string.format('[%d/%d] ', tab.tab_index + 1, #tabs) or ''
    return zoomed .. index .. title
  end)

end

return module
