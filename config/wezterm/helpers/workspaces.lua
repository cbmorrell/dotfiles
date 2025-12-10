local wezterm = require 'wezterm'
local act = wezterm.action

local module = {}

local mods = 'CMD'

local function create_workspace_with_number(window, pane)
  window:perform_action(
    act.PromptInputLine {
      description = 'Workspace name (optional)',
      action = wezterm.action_callback(function(win, p, name)
        if not name or name == '' then
          name = 'ws-' .. tostring(os.time())
        end

        win:perform_action(
          act.PromptInputLine {
            description = 'Number to map (1-9, required)',
            action = wezterm.action_callback(function(win2, p2, num)
              if not num or num == '' then
                return
              end

              local n = tonumber(num)
              if not n or n < 1 or n > 9 then
                wezterm.log_error('Invalid workspace number: ' .. tostring(num))
                return
              end

              local num_str = tostring(n)

              -- record mapping for this session (string key!)
              wezterm.GLOBAL.ws_map[num_str] = name
              wezterm.log_info('Mapped ' .. mods .. '+' .. num_str .. ' to workspace ' .. name)

              -- switch to that workspace now
              win2:perform_action(
                act.SwitchToWorkspace { name = name },
                p2
              )
            end),
          },
          p
        )
      end),
    },
    pane
  )
end


function module.setup(config)
  -- Session-only mapping: string number -> workspace name
  wezterm.GLOBAL.ws_map = wezterm.GLOBAL.ws_map or {}

  -- One handler per number that looks up ws_map and switches
  for i = 1, 9 do
    local num_str = tostring(i)
    local event_name = 'goto_workspace_' .. num_str

    wezterm.on(event_name, function(window, pane)
      local map = wezterm.GLOBAL.ws_map or {}
      local ws = map[num_str]

      if ws then
        wezterm.log_info('Switching to workspace ' .. ws .. ' for ' .. mods .. '+' .. num_str)
        window:perform_action(
          act.SwitchToWorkspace { name = ws },
          pane
        )
      else
        wezterm.log_info('No workspace mapped to ' .. mods .. '+' .. num_str)
        -- you could optionally prompt here if unmapped
      end
    end)
  end

  -- Show the workspace name on the right
  wezterm.on("update-right-status", function(window)
    window:set_right_status(window:active_workspace() .. "   ") -- add spaces for padding
  end)

  -- List for create_workspace_with_number event
  wezterm.on('create_workspace_with_number', create_workspace_with_number)

  -- Add fixed mods+1..9 keys that emit events
  local workspace_keys = {
    {
      key='N',
      mods='CMD|SHIFT',
      action=act.EmitEvent 'create_workspace_with_number'
    },
    { key = "]", mods = "CMD|SHIFT", action = act.SwitchWorkspaceRelative(1) },
    { key = "[", mods = "CMD|SHIFT", action = act.SwitchWorkspaceRelative(-1) },
    {
      key = '9',
      mods = 'CMD|SHIFT',
      action = act.ShowLauncherArgs {
        flags = 'FUZZY|WORKSPACES',
      }
    }
  }

  for i = 1, 9 do
    table.insert(workspace_keys, {
      key = tostring(i),
      mods = mods,
      action = act.EmitEvent('goto_workspace_' .. tostring(i)),
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
