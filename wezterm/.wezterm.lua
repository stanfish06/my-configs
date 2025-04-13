local wezterm = require("wezterm")
local config = wezterm.config_builder()
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local act = wezterm.action

workspace_switcher.apply_to_config(config)

config.window_background_opacity = 0.85
config.text_background_opacity = 1.0
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
	active_titlebar_bg = "#333333",
}

config.use_fancy_tab_bar = false
config.tab_max_width = 48

wezterm.on("update-status", function(window)
	local color_scheme = window:effective_config().resolved_palette
	local bg = color_scheme.background
	local fg = color_scheme.foreground
	local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

	window:set_right_status(wezterm.format({
		{ Foreground = { Color = "#2e7d32" } },
		{ Text = SOLID_LEFT_ARROW },
		{ Attribute = { Intensity = "Bold" } },
		{ Foreground = { Color = "#000000" } },
		{ Background = { Color = "#2e7d32" } },
		{ Text = " " .. window:active_workspace() .. " " },
		{ Foreground = { Color = "#66bb6a" } },
		{ Text = SOLID_LEFT_ARROW },
		{ Attribute = { Intensity = "Bold" } },
		{ Foreground = { Color = "#000000" } },
		{ Background = { Color = "#66bb6a" } },
		{ Text = " " .. wezterm.hostname() .. " " },
		{ Foreground = { Color = "#a5d6a7" } },
		{ Text = SOLID_LEFT_ARROW },
		{ Attribute = { Intensity = "Bold" } },
		{ Foreground = { Color = "#000000" } },
		{ Background = { Color = "#a5d6a7" } },
		{ Text = " " .. wezterm.strftime("%a %b %-d %H:%M") .. " " },
	}))
end)

config.colors = {
	tab_bar = {
		active_tab = {
			bg_color = "#d87850",
			fg_color = "#000000",
			italic = true,
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#0f3b6c",
			fg_color = "#ffffff",
			italic = true,
			intensity = "Bold",
		},
	},
}

config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }
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
	{
		key = "s",
		mods = "LEADER",
		action = workspace_switcher.switch_workspace(),
	},
	{
		key = "w",
		mods = "ALT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
		end),
	},
	{
		key = "r",
		mods = "LEADER",
		action = wezterm.action_callback(function(win, pane)
			resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
				local type = string.match(id, "^([^/]+)") -- match before '/'
				id = string.match(id, "([^/]+)$") -- match after '/'
				id = string.match(id, "(.+)%..+$") -- remove file extention
				local opts = {
					relative = true,
					restore_text = true,
					on_pane_restore = resurrect.tab_state.default_on_pane_restore,
				}
				if type == "workspace" then
					local state = resurrect.state_manager.load_state(id, "workspace")
					resurrect.workspace_state.restore_workspace(state, opts)
				elseif type == "window" then
					local state = resurrect.state_manager.load_state(id, "window")
					resurrect.window_state.restore_window(pane:window(), state, opts)
				elseif type == "tab" then
					local state = resurrect.state_manager.load_state(id, "tab")
					resurrect.tab_state.restore_tab(pane:tab(), state, opts)
				end
			end)
		end),
	},
}

config.ssh_domains = { {
	name = "greatlakes",
	remote_address = "greatlakes.arc-ts.umich.edu",
	username = "zyyu",
} }

config.launch_menu = {
	{
		label = "greatlakes",
		args = { "ssh", "zyyu@greatlakes.arc-ts.umich.edu" },
	},
	{
		label = "msvc",
		args = {
			"cmd.exe",
			"/k",
			"C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\Common7\\Tools\\VsDevCmd.bat",
			"-arch=x64",
		},
	},
}

return config
