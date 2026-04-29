local wezterm = require 'wezterm'

local module = {}

function module.setup(config)
  -- For example, changing the color scheme:
  config.color_schemes = {
    ["Shale"] = {
      -- Background / surfaces
      background              = "#1e2124",
      foreground              = "#c8cdd4",

      -- Cursor
      cursor_bg               = "#c8cdd4",
      cursor_fg               = "#1e2124",
      cursor_border           = "#c8cdd4",

      -- Selection
      selection_bg            = "#2e3438",
      selection_fg            = "#c8cdd4",

      -- Split pane divider
      split                   = "#3a4046",

      -- Scrollbar
      scrollbar_thumb         = "#3a4046",

      -- ANSI Colors (normal)
      ansi = {
        "#2e3438",  -- black   (color0)
        "#c4756a",  -- red     (color1)
        "#7ea87e",  -- green   (color2)
        "#c9a96e",  -- yellow  (color3)
        "#6d8fad",  -- blue    (color4)
        "#9d86b5",  -- magenta (color5)
        "#6aabaa",  -- cyan    (color6)
        "#c8cdd4",  -- white   (color7)
      },

      -- ANSI Colors (bright)
      brights = {
        "#3a4046",  -- bright black   (color8)
        "#d4877c",  -- bright red     (color9)
        "#8fba8f",  -- bright green   (color10)
        "#d9b97e",  -- bright yellow  (color11)
        "#7ea0be",  -- bright blue    (color12)
        "#ae98c6",  -- bright magenta (color13)
        "#7bbcbb",  -- bright cyan    (color14)
        "#dde1e6",  -- bright white   (color15)
      },

      -- Tab bar
      tab_bar = {
        background = "#181b1e",

        active_tab = {
          bg_color  = "#1e2124",
          fg_color  = "#c8cdd4",
          intensity = "Normal",
          underline = "None",
          italic    = false,
          strikethrough = false,
        },

        inactive_tab = {
          bg_color  = "#181b1e",
          fg_color  = "#5a6370",
        },

        inactive_tab_hover = {
          bg_color  = "#242830",
          fg_color  = "#9aa3ae",
          italic    = false,
        },

        new_tab = {
          bg_color  = "#181b1e",
          fg_color  = "#5a6370",
        },

        new_tab_hover = {
          bg_color  = "#242830",
          fg_color  = "#9aa3ae",
          italic    = false,
        },
      },
    },
  }
  config.color_scheme = "rose-pine"
  -- default highlight colour is invisible on rose-pine, so add custom ones based on rose-pine theme
  config.colors = {
    selection_bg = "#332D41",  -- rose-pine iris blended at 15% over base (matches nvim Visual)
    selection_fg = "#e0def4",  -- rose-pine text
  }
  config.font = wezterm.font("MesloLGS Nerd Font")

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
