-- Leader Key:
-- The leader key is set to ALT + q, with a timeout of 2000 milliseconds (2 seconds).
-- To execute any keybinding, press the leader key (ALT + q) first, then the corresponding key.

-- Keybindings:
-- 1. Tab Management:
--    - ALT + t: Create a new tab in the current pane's domain.
--    - ALT + w: Close the current pane (with confirmation).
--    - ALT + b: Switch to the previous tab.
--    - ALT + n: Switch to the next tab.
--    - ALT + <number>: Switch to a specific tab (0–9).

-- 2. Pane Splitting:
--    - ALT + .: Split the current pane horizontally into two panes.
--    - ALT + -: Split the current pane vertically into two panes.
-- 3. Pane Navigation:
--    - ALT + h: Move to the pane on the left.
--    - ALT + j: Move to the pane below.
--    - ALT + k: Move to the pane above.
--    - ALT + l: Move to the pane on the right.

-- 4. Pane Resizing:
--    - ALT + Ctrl + h: Increase the pane size to the left by 5 units.
--    - ALT + Ctrl + j: Increase the pane size to the right by 5 units.
--    - ALT + Ctrl + k: Increase the pane size downward by 5 units.
--    - ALT + Ctrl + l: Increase the pane size upward by 5 units.

local wezterm = require("wezterm")
local config = {}

config.color_scheme = "kanagawabones"

config.font_size = 14.0
config.font = wezterm.font("Terminess Nerd Font Mono")

config.max_fps = 240
config.animation_fps = 240

config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = true
config.hide_tab_bar_if_only_one_tab = true

config.keys = {
	{
		mods = "ALT",
		key = "t",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	{
		mods = "ALT",
		key = "q",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		mods = "ALT|SHIFT",
		key = "Tab",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{
		mods = "ALT",
		key = "b",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{
		mods = "ALT",
		key = "Tab",
		action = wezterm.action.ActivateTabRelative(1),
	},
	{
		mods = "ALT",
		key = "n",
		action = wezterm.action.ActivateTabRelative(1),
	},
	{
		mods = "ALT",
		key = ".",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "ALT",
		key = "-",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "ALT",
		key = "h",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		mods = "ALT",
		key = "j",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		mods = "ALT",
		key = "k",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		mods = "ALT",
		key = "l",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		mods = "ALT|CTRL",
		key = "h",
		action = wezterm.action.AdjustPaneSize({ "Left", 5 }),
	},
	{
		mods = "ALT|CTRL",
		key = "l",
		action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
	},
	{
		mods = "ALT|CTRL",
		key = "j",
		action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
	},
	{
		mods = "ALT|CTRL",
		key = "k",
		action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
	},
}

for i = 0, 9 do
	-- leader + number to activate that tab
	table.insert(config.keys, {
		key = tostring(i),
		mods = "ALT",
		action = wezterm.action.ActivateTab(i),
	})
end

return config
