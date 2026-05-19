local wezterm = require 'wezterm'
local act = wezterm.action
local tables = require 'helpers.tables'

local module = {}

function build_window_title_key(window_id)
  return 'window_title_' .. window_id
end

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
    -- Fuzzy finder for all open windows
    {key="o", mods="CMD|SHIFT", action=wezterm.action_callback(function(window, pane)
      local choices = {}
      for _, win in ipairs(wezterm.mux.all_windows()) do
        local id = win:window_id()
        local custom_title = wezterm.GLOBAL[build_window_title_key(id)]
        local tab_title = win:active_tab():get_title()
        local pane_title = win:active_tab():active_pane():get_title()
        local label = custom_title or (tab_title ~= '' and tab_title) or (pane_title ~= '' and pane_title) or ('Window ' .. id)
        local workspace = win:get_workspace()
        if workspace ~= 'default' then
          label = '[' .. workspace .. '] ' .. label
        end
        table.insert(choices, { id = tostring(id), label = label })
      end
      window:perform_action(
        act.InputSelector {
          title = 'Windows',
          fuzzy = true,
          choices = choices,
          action = wezterm.action_callback(function(_, _, id, _)
            if not id then return end
            local win_id = tonumber(id)
            for _, win in ipairs(wezterm.mux.all_windows()) do
              if win:window_id() == win_id then
                local gui_win = win:gui_window()
                if gui_win then gui_win:focus() end
                return
              end
            end
          end),
        },
        pane
      )
    end)},
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
            if line == nil then return end  -- exited early
            local title
            if line == '' then
              -- Clear title
              title = nil
            else
              title = line
            end
            local key = build_window_title_key(inner_window:window_id())
            wezterm.GLOBAL[key] = title
          end),
        },
        pane
      )
    end)},
  }

  tables.extend_table(config.keys, navigation_keys)

  wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
    local key = build_window_title_key(tab.window_id)
    local custom = wezterm.GLOBAL[key]
    local title = custom or tab.active_pane.title

    local zoomed = tab.active_pane.is_zoomed and '[Z] ' or ''
    local index = #tabs > 1 and string.format('[%d/%d] ', tab.tab_index + 1, #tabs) or ''
    return zoomed .. index .. title
  end)

end

return module
