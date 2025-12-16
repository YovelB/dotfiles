local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- general
-- config.term = "wezterm"

-- to fix snacks image rendering
-- https://github.com/kovidgoyal/kitty/blob/master/terminfo/kitty.terminfo
-- run this cmd for the github link above to install xterm kitty
-- tempfile=$(mktemp) && curl -o "$tempfile" https://raw.githubusercontent.com/kovidgoyal/kitty/master/terminfo/kitty.terminfo && tic -x -o ~/.terminfo "$tempfile"
config.term = "xterm-kitty"
config.enable_kitty_graphics = true

-- config.front_end = "WebGpu"
-- config.webgpu_power_preference = "HighPerformance"
config.enable_wayland = true
config.scrollback_lines = 10000

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
config.cursor_blink_rate = 0

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
