local wezterm = require("wezterm")
local config = wezterm.config_builder()
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local act = wezterm.action
local domains = wezterm.plugin.require("https://github.com/DavidRR-F/quick_domains.wezterm")

workspace_switcher.apply_to_config(config)

config.window_decorations = "RESIZE"
-- config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
-- config.integrated_title_button_alignment = "Left"
-- this is not used when fancy bar is off
-- config.integrated_title_button_style = "Gnome"
config.window_background_opacity = 0
config.text_background_opacity = 1.0
config.win32_system_backdrop = "Tabbed"
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
config.show_new_tab_button_in_tab_bar = false

wezterm.on("update-right-status", function(window, pane)
	window:set_right_status(window:active_workspace())
end)

config.window_frame = {
	font = wezterm.font({ family = "JetBrains Mono", weight = "Bold" }),
	font_size = 10.0,
}

config.max_fps = 120
config.use_fancy_tab_bar = false
config.tab_max_width = 999
config.initial_rows = 24
config.initial_cols = 120
config.tab_bar_at_bottom = true

function basename(path)
	return path:match("([^/\\]+)$")
end

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
		{ Text = " " .. basename(window:active_workspace()) .. " " },
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

function get_max_cols(window)
	local tab = window:active_tab()
	local cols = tab:get_size().cols
	return cols
end

wezterm.on("window-config-reloaded", function(window)
	wezterm.GLOBAL.cols = get_max_cols(window)
end)

wezterm.on("window-resized", function(window, pane)
	wezterm.GLOBAL.cols = get_max_cols(window)
end)

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local max_tab_region_width = 0.5 * wezterm.GLOBAL.cols // #tabs
	local title = basename(tab.active_pane.title)
	if #title > max_tab_region_width then
		title = wezterm.truncate_right(title, max_tab_region_width)
		if max_tab_region_width <= 3 then
			title = ""
		end
	end
	local full_title = "[" .. tab.tab_index + 1 .. "] " .. title
	local pad_length = (wezterm.GLOBAL.cols * 0.6 // #tabs - #full_title) // 2
	if pad_length * 2 + #full_title > max_width then
		pad_length = (max_width - #full_title) // 2
	end
	return string.rep(" ", pad_length) .. full_title .. string.rep(" ", pad_length)
end)

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

-- for quick domains
domains.apply_to_config(config, {
	keys = {
		attach = {
			key = "d",
			mods = "LEADER",
		},
		vsplit = {
			key = "-",
			mods = "LEADER",
		},
		hsplit = {
			key = "Backslash",
			mods = "LEADER",
		},
	},
})

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
