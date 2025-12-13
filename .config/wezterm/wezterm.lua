local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- general
config.term = "wezterm"
config.enable_wayland = false
config.webgpu_power_preference = "HighPerformance"
config.scrollback_lines = 10000
config.enable_kitty_graphics = true

-- tab
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
-- window
config.window_decorations = "NONE"
-- for gnome set left=5 and top=5 (for niri only top=4)
config.window_padding = { left = 0, right = 0, top = 4, bottom = 0 }

-- fonts
config.font_size = 14.5
config.font = wezterm.font_with_fallback({ "JetBrains Mono Nerd Font", "JetBrains Mono", "Noto Color Emoji" })
-- colorscheme
config.color_scheme = "Tokyo Night"
-- cursor
config.default_cursor_style = "SteadyBar"

-- hebrew / bidi support
config.bidi_enabled = true
config.bidi_direction = "LeftToRight"

-- fullscreen (not needed for niri)
-- this event triggers when WezTerm starts
-- wezterm.on("gui-startup", function(cmd)
-- 	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
-- 	-- f11 fullscreen (for with os bars use maximize() instead)
-- 	window:gui_window():toggle_fullscreen()
-- end)

return config
