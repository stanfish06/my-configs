local wezterm = require("wezterm")
local config = wezterm.config_builder()
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local domains = wezterm.plugin.require("https://github.com/DavidRR-F/quick_domains.wezterm")
local act = wezterm.action

config.font_size = 20

workspace_switcher.apply_to_config(config)

-- disable this otherwise window will exceeds boundary in sway
-- config.window_decorations = "RESIZE"
local dimmer = { brightness = 0.05 }
config.background = {
	{
		source = { File = "/home/stanfish/Git/my-configs/img/dark-green-forest.jpg" },
		opacity = 1.0,
		hsb = dimmer,
	},
}
-- config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
-- config.integrated_title_button_alignment = "Left"
-- this is not used when fancy bar is off
-- config.integrated_title_button_style = "Gnome"
-- config.window_background_opacity = 0.3
-- config.text_background_opacity = 1.0
-- use this if you want to by default run linux
-- some good fonts:
-- JetBrainsMono Nerd Font (good in general)
-- config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Regular", italic = false })
-- config.line_height = 0.925
-- Cascadia Code (round and nice)
-- config.font = wezterm.font("Cascadia Code", { weight = "Regular", italic = false })
-- Fira Code (similar to JetBrainsMono)
-- config.font = wezterm.font("Fira Code", { weight = "Medium", italic = false })
-- config.line_height = 0.9
-- Maple Mono NF (round and nice)
-- config.font = wezterm.font("Maple Mono NF", { weight = "Regular", italic = false })
-- config.line_height = 0.875
-- Victor Mono (looking nice for regular chars but too twisted for italic and thin, better to use maple for italic)
config.font = wezterm.font("VictorMono Nerd Font Mono", { weight = "DemiBold", italic = false })
config.line_height = 0.885
-- config.font = wezterm.font("Iosevka", { stretch = "SemiExpanded", weight = "Regular" })
-- config.font = wezterm.font("Perfect Dos Vga 437 Win", { weight = "DemiLight", italic = false })
-- more complex settings
-- only appenlied to italic words
config.font_rules = {
	{
		intensity = "Bold",
		italic = true,
		font = wezterm.font({ family = "Maple Mono NF", weight = "Bold", style = "Italic" }),
	},
	{
		italic = true,
		intensity = "Half",
		font = wezterm.font({ family = "Maple Mono NF", weight = "DemiBold", style = "Italic" }),
	},
	{
		italic = true,
		intensity = "Normal",
		font = wezterm.font({ family = "Maple Mono NF", style = "Italic" }),
	},
}
-- config.window_frame = {
-- 	font = wezterm.font({ family = "Iosevka", weight = "Bold" }),
-- 	font_size = 10.0,
-- }

-- apparently there are some fonts that windows terminal uses taht wezterm cannot figure out
-- check it back later as this issue is still open
config.color_scheme = "Rosé Pine (base16)"
-- config.color_scheme = "Tokyo Night"
-- config.color_scheme = "Tokyo Night Storm (Gogh)"
config.show_new_tab_button_in_tab_bar = false
config.adjust_window_size_when_changing_font_size = false
config.command_palette_font_size = 20
config.command_palette_bg_color = "#394B70"
config.command_palette_fg_color = "#E0DEF4"
config.bold_brightens_ansi_colors = true
config.enable_kitty_graphics = true
config.enable_wayland = true
config.window_padding = { left = 5, right = 5, top = 0, bottom = 0 }

config.max_fps = 165
config.use_fancy_tab_bar = false
config.tab_max_width = 999
config.initial_rows = 24
config.initial_cols = 120
config.tab_bar_at_bottom = true

-- for kill workspaces
function filter_panes(tbl, callback)
	local filt_table = {}

	for i, v in ipairs(tbl) do
		if callback(v, i) then
			table.insert(filt_table, v)
		end
	end
	return filt_table
end

function kill_workspace(workspace)
	local success, stdout = wezterm.run_child_process({ "wezterm", "cli", "list", "--format=json" })

	if success then
		local json = wezterm.json_parse(stdout)
		if not json then
			return
		end

		local workspace_panes = filter_panes(json, function(p)
			return p.workspace == workspace
		end)

		for _, p in ipairs(workspace_panes) do
			wezterm.run_child_process({
				"wezterm",
				"cli",
				"kill-pane",
				"--pane-id=" .. p.pane_id,
			})
		end
	end
end

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
	background = "#1E1E1E",
	cursor_bg = "#FFA500",
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
	local max_tab_region_width = 0.4 * wezterm.GLOBAL.cols // #tabs
	local title = basename(tab.active_pane.title)
	if #title > max_tab_region_width then
		title = wezterm.truncate_right(title, max_tab_region_width)
		if max_tab_region_width <= 3 then
			title = ""
		end
	end
	local full_title = "[" .. tab.tab_index + 1 .. "] " .. title
	local pad_length = (wezterm.GLOBAL.cols * 0.2 // #tabs - #full_title) // 2
	if pad_length * 2 + #full_title > max_width then
		pad_length = (max_width - #full_title) // 2
	end
	return string.rep(" ", pad_length) .. full_title .. string.rep(" ", pad_length)
end)

-- CTRL + SPACE is reserved for emacs
-- CTRL + A is for tmux
-- SPACE is for neovim
config.leader = { key = "`", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{
		key = "-",
		mods = "CTRL|ALT",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "Backslash",
		mods = "CTRL|ALT",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "k",
		mods = "CTRL|ALT",
		action = act.CloseCurrentPane({ confirm = true }),
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
		key = "q",
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
		key = "n",
		mods = "CTRL|ALT",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Enter name for new workspace" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
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
		key = "k",
		mods = "LEADER",
		action = wezterm.action_callback(function(window)
			local w = window:active_workspace()
			kill_workspace(w)
		end),
	},
	{
		key = "E",
		mods = "CTRL|SHIFT",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{
					Text = "Enter new name for this workspace"
				},
			}),
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
				end
			end),
		}),
	},
}

-- for quick domains
domains.apply_to_config(config, {
	keys = {
		attach = {
			key = "a",
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

-- wezterm will automatically connect to unix mux server
config.unix_domains = {
	{
		name = "unix",
	},
}
-- this will only work when launching wezterm-gui, not wezterm
config.default_gui_startup_args = { "connect", "unix" }

return config
