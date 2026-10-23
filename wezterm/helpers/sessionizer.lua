local wezterm = require 'wezterm'
local act = wezterm.action
local tables = require 'helpers.tables'
local navigation = require 'helpers.navigation'

local module = {}

-- Full path because WezTerm launched from the Dock doesn't have Homebrew on its PATH
local FD_PATH = '/opt/homebrew/bin/fd'

local function file_exists(path)
  local file = io.open(path, 'r')
  if file then file:close() end
  return file ~= nil
end

-- Returns the directories under search_dir that contain a .git directory.
-- Uses fd when installed (faster, and skips gitignored directories like node_modules),
-- otherwise falls back to find.
local function find_git_repos(search_dir)
  local repos = {}
  if file_exists(FD_PATH) then
    local success, stdout = wezterm.run_child_process {
      FD_PATH, '--hidden', '--type', 'd', '--max-depth', '4',
      '--glob', '.git', search_dir, '--format', '{//}', -- {//} = parent dir of .git
    }
    if success then
      for repo in stdout:gmatch('[^\n]+') do
        table.insert(repos, repo)
      end
    end
  else
    local success, stdout = wezterm.run_child_process {
      'find', search_dir, '-name', '.git', '-type', 'd', '-maxdepth', '4',
    }
    if success then
      for git_dir in stdout:gmatch('[^\n]+') do
        table.insert(repos, git_dir:sub(1, -6)) -- strip trailing /.git
      end
    end
  end
  return repos
end

local function find_projects(search_dirs)
  local choices = {}
      -- TODO: Make this faster with fd?
  for _, search_dir in ipairs(search_dirs) do
    for _, project_dir in ipairs(find_git_repos(search_dir)) do
      local label = project_dir:sub(#search_dir + 2) -- relative path from search_dir
      table.insert(choices, { id = project_dir, label = label })
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
