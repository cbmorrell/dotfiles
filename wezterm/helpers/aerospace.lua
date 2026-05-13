local wezterm = require 'wezterm'
local act = wezterm.action
local tables = require 'helpers.tables'

local module = {}

function module.setup(config)
  tables.extend_table(config.keys, {
    {
      key = 'W',
      mods = 'CMD|SHIFT',
      action = wezterm.action_callback(function(window, pane)
        local success, stdout = wezterm.run_child_process {
          '/opt/homebrew/bin/aerospace', 'list-windows', '--all',
          '--format', '%{window-id} | %{workspace} | %{app-bundle-id} | %{window-title}',
        }
        if not success then return end

        local choices = {}
        for line in stdout:gmatch('[^\n]+') do
          local id, ws, bundle, title = line:match('^(%d+)%s*|%s*(.-)%s*|%s*(.-)%s*|%s*(.-)%s*$')
          if id and bundle == 'com.github.wez.wezterm' then
            table.insert(choices, {
              id = id,
              label = '[' .. ws .. '] ' .. title,
            })
          end
        end

        table.sort(choices, function(a, b) return a.label < b.label end)

        window:perform_action(
          act.InputSelector {
            title = 'Windows',
            fuzzy = true,
            choices = choices,
            action = wezterm.action_callback(function(_, _, id)
              if not id then return end
              wezterm.run_child_process { '/opt/homebrew/bin/aerospace', 'focus', '--window-id', id }
            end),
          },
          pane
        )
      end),
    },
  })
end

return module
