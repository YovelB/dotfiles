local wezterm = require("wezterm")

local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
	if mux then
		local _, _, window = mux.spawn_window(cmd or {})
		wezterm.sleep_ms(50)
		window:gui_window():maximize()
	end
end)

return {
	enable_tab_bar = false, -- disable the tab bar (internal multiplexer)
	color_scheme = "Tokyo Night",
	font = wezterm.font("JetBrains Mono"),
	font_size = 15.0,
	window_decorations = "NONE",

	default_cursor_style = "SteadyBar",

	window_padding = {
		left = 5,
		right = 0,
		top = 0,
		bottom = 0,
	},

	scrollback_lines = 5000, -- Set the scrollback buffer size

	window_frame = { active_titlebar_bg = "#1a1b26" }, -- Match Tokyo Night theme
	colors = {
		foreground = "#c0caf5",
		background = "#1a1b26",
		cursor_bg = "#c0caf5",
		cursor_border = "#c0caf5",
		cursor_fg = "#1a1b26",
		selection_bg = "#33467c",
		selection_fg = "#c0caf5",
		ansi = { "#15161e", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#a9b1d6" },
		brights = { "#414868", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#c0caf5" },
	},
}
