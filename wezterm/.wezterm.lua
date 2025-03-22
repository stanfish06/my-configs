local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

config.window_background_opacity = 0.85
config.text_background_opacity = 0.5
config.enable_kitty_graphics = true
config.default_prog = { "pwsh.exe", "-NoLogo" }
-- use this if you want to by default run linux
-- config.default_domain = "WSL:Ubuntu"
config.font = wezterm.font("JetBrains Mono", { weight = "Regular", italic = false })
-- apparently there are some fonts that windows terminal uses taht wezterm cannot figure out
-- check it back later as this issue is still open
config.warn_about_missing_glyphs = false
config.color_scheme = "Rosé Pine (base16)"
-- note for windows:
-- you need Go to the Nvidia control panel >
-- Manage 3d Settings, select the program settings tab,
-- and select/add WezTerm.
-- Scroll down to OpenGL GDI compatibility and
-- set it to "Prefer compatible."
config.front_end = "OpenGL"

wezterm.on("update-right-status", function(window, pane)
	window:set_right_status(window:active_workspace())
end)

config.window_frame = {
	font = wezterm.font({ family = "JetBrains Mono", weight = "Bold" }),
	font_size = 10.0,
}

config.keys = {
	{
		key = "-",
		mods = "CTRL",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "-",
		mods = "CTRL|ALT",
		action = act.SplitVertical({
			args = { "wsl.exe" },
		}),
	},
	{
		key = "Backslash",
		mods = "CTRL",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "Backslash",
		mods = "CTRL|ALT",
		action = act.SplitHorizontal({
			args = { "wsl.exe" },
		}),
	},
	-- Switch to the default workspace
	{
		key = "y",
		mods = "CTRL|SHIFT",
		action = act.SwitchToWorkspace({
			name = "default",
		}),
	},
	{
		key = "9",
		mods = "ALT",
		action = act.ShowLauncherArgs({
			flags = "FUZZY|WORKSPACES",
		}),
	},
	{
		key = "F11",
		action = act.ToggleFullScreen,
	},
	{
		key = "W",
		mods = "CTRL|SHIFT",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Enter name for new workspace" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:perform_action(
						act.SwitchToWorkspace({
							name = line,
						}),
						pane
					)
				end
			end),
		}),
	},
}

config.launch_menu = {
	{
		label = "greatlakes",
		args = { "ssh", "zyyu@greatlakes.arc-ts.umich.edu" },
	},
}

return config
