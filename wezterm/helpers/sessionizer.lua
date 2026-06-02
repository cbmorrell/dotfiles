local wezterm = require 'wezterm'
local act = wezterm.action
local tables = require 'helpers.tables'
local navigation = require 'helpers.navigation'

local module = {}

local function find_projects(search_dirs)
  local choices = {}
  for _, search_dir in ipairs(search_dirs) do
    local success, stdout = wezterm.run_child_process {
      'find', search_dir, '-name', '.git', '-type', 'd', '-maxdepth', '5',
    }
    if success then
      for dir in stdout:gmatch('[^\n]+') do
        local project_dir = dir:sub(1, -6) -- strip trailing /.git
        local label = project_dir:sub(#search_dir + 2) -- relative path from search_dir
        table.insert(choices, { id = project_dir, label = label })
      end
    end
  end
  table.sort(choices, function(a, b) return a.label < b.label end)
  return choices
end

local function find_window_by_name(name)
  for _, win in ipairs(wezterm.mux.all_windows()) do
    local id = win:window_id()
    if wezterm.GLOBAL[navigation.build_window_title_key(id)] == name then
      return win
    end
  end
  return nil
end

function module.setup(config, search_dirs)
  tables.extend_table(config.keys, {
    {
      key = 'p',
      mods = 'CMD|SHIFT',
      action = wezterm.action_callback(function(window, pane)
        local choices = find_projects(search_dirs)
        window:perform_action(
          act.InputSelector {
            title = 'Projects',
            fuzzy = true,
            choices = choices,
            action = wezterm.action_callback(function(_, _, id, label)
              if not id then return end
              local existing = find_window_by_name(label)
              if existing then
                local gui_win = existing:gui_window()
                if gui_win then gui_win:focus() end
              else
                local _, _, new_win = wezterm.mux.spawn_window { cwd = id }
                wezterm.GLOBAL['window_title_' .. new_win:window_id()] = label
                local gui_win = new_win:gui_window()
                if gui_win then gui_win:focus() end
              end
            end),
          },
          pane
        )
      end),
    },
  })
end

return module
