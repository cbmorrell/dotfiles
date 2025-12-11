local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

local module = {}

local ws_map = {}
local mods = 'CMD'

-- Helper: does this workspace currently exist?
local function workspace_exists(name)
  for _, ws in ipairs(mux.get_workspace_names()) do
    if ws == name then
      return true
    end
  end
  return false
end

local function get_workspace_number(name)
  for number, ws in pairs(ws_map) do
    if ws == name then
      return number
    end
  end
  return nil
end

function module.setup(config)
  -- Session-only mapping: string number -> workspace name
  ws_map = {} -- this will reset every time config is loaded, but using the global variable saves things as userdata and messes things up

  -- Show the workspace name on the right
  wezterm.on("update-right-status", function(window)
    local ws = window:active_workspace()
    local number = get_workspace_number(ws)
    if number then
      ws = ws .. ' (' .. number .. ')'
    end

    window:set_right_status(ws .. "   ") -- add spaces for padding
  end)


  local workspace_keys = {
    -- Create workspace with name
    {
      key='N',
      mods='CMD|SHIFT',
      action=act.PromptInputLine {
        description = wezterm.format {
          {Attribute={Intensity='Bold'}},
          {Foreground={AnsiColor='Fuchsia'}},
          {Text='Enter name for new workspace'},
        },
        action=wezterm.action_callback(function(window, pane, line)
          -- line is:
          --   nil  -> user hit Esc / cancelled
          --   ""   -> user hit Enter on empty input
          --   text -> whatever they typed
          local name
          if line and line ~= '' then
            name = line
          else
            name = nil
          end

          if workspace_exists(name) then
            wezterm.log_info("Workspace '" .. name .. "' already exists.")
            return
          end

          window:perform_action(
            act.SwitchToWorkspace {
              name=name,
            },
            pane
          )
        end),
      },
    },
    { key = "]", mods = "CMD|SHIFT", action = act.SwitchWorkspaceRelative(1) },
    { key = "[", mods = "CMD|SHIFT", action = act.SwitchWorkspaceRelative(-1) },
    {
      key = 'W',
      mods = 'CMD|SHIFT',
      action = act.ShowLauncherArgs {
        flags = 'FUZZY|WORKSPACES',
      }
    }
  }

  -- Add actions for mods+1..9 keys
  for i = 1, 9 do
    local num_str = tostring(i)
    table.insert(workspace_keys, {
      key = num_str,
      mods = mods,
      action = wezterm.action_callback(function(window, pane)
        local current_ws = window:active_workspace()

        if ws_map[num_str] == current_ws then
          wezterm.log_info('Already in mapped workspace.')
          return
        end

        if ws_map[num_str] and not workspace_exists(ws_map[num_str]) then
          -- Cleanup workspaces that previously existed but have been closed
          wezterm.log_info('Clearing workspace ' .. ws_map[num_str])
          ws_map[num_str] = nil
        end

        if not ws_map[num_str] then
          -- No workspace is mapped to this number - set new mapping
          local current_number = get_workspace_number(current_ws)
          if current_number then
            -- Mapping for this workspace already exists - clear it
            ws_map[current_number] = nil
          end

          ws_map[num_str] = current_ws
        end

        wezterm.log_info('Switching to workspace ' .. ws_map[num_str] .. ' for ' .. mods .. '+' .. num_str)
        window:perform_action(
          act.SwitchToWorkspace { name = ws_map[num_str] },
          pane
        )
      end)
    })
  end

  for _, item in ipairs(workspace_keys) do
    table.insert(config.keys, item)
  end

end

-- local mux = wezterm.mux
-- When the workspace changes, try to restore the previous active window
-- local last_window_for_workspace = {}

-- -- Track active window changes
-- wezterm.on("window-focus-changed", function(window, pane)
--   local ws = window:active_workspace()
--   local id = window:window_id()
--   last_window_for_workspace[ws] = id
-- end)
--
-- -- When the workspace changes, try to restore the previous window for it
-- wezterm.on("workspace-changed", function(window, pane)
--   local ws = window:active_workspace()
--   local wanted_id = last_window_for_workspace[ws]
--
--   if wanted_id then
--     for _, win in ipairs(mux.all_windows()) do
--       if win:window_id() == wanted_id and win:active_workspace() == ws then
--         win:focus()
--         return
--       end
--     end
--   end
-- end)

return module
