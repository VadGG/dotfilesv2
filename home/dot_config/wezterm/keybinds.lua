local M = { }

local wezterm = require("wezterm")
local act = wezterm.action
local utils = require("utils")

---------------------------------------------------------------
--- helper functions
---------------------------------------------------------------
local function is_multiplexer(pane)
  local process_info = pane:get_foreground_process_info()
  local process_name = process_info and process_info.name

  return process_name == "zellij"
end

local function is_file_browser(pane)
  local process_info = pane:get_foreground_process_info()
  local process_name = process_info and process_info.name

  return process_name == "broot" or process_name == "nnn" or  process_name == "lf" or  process_name == "yazi"
end

local function is_editor(pane)
  local process_info = pane:get_foreground_process_info()
  local process_name = process_info and process_info.name

  return process_name == "nvim" or process_name == "vim" or process_name == "hx"
end

---------------------------------------------------------------
--- keybinds
---------------------------------------------------------------
M.tmux_keybinds = {
	{ key = "h", mods = "ALT", action = act({ ActivatePaneDirection = "Left" }) },
	{ key = "l", mods = "ALT", action = act({ ActivatePaneDirection = "Right" }) },
	{ key = "k", mods = "ALT", action = act({ ActivatePaneDirection = "Up" }) },
	{ key = "j", mods = "ALT", action = act({ ActivatePaneDirection = "Down" }) },

	{ key = "n", mods = "ALT|CTRL", action = act({ SpawnTab = "CurrentPaneDomain" }) },
	{ key = "h", mods = "ALT|CTRL", action = act({ ActivateTabRelative = -1 }) },
	{ key = "l", mods = "ALT|CTRL", action = act({ ActivateTabRelative = 1 }) },

	{ key = "j", mods = "ALT|SHIFT", action = act({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
	{ key = "l", mods = "ALT|SHIFT", action = act({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },

  { key = "z", mods = "ALT", action = wezterm.action.TogglePaneZoomState},

	{ key = "x", mods = "ALT", action = act({ CloseCurrentPane = { confirm = true } }) },
	{ key = "x", mods = "ALT|CTRL|SHIFT", action = act({ CloseCurrentTab = { confirm = true } }) },

	{ key = "y", mods = "ALT|CTRL", action = act({ EmitEvent = "trigger-nvim-with-scrollback" }) },
	{
		key = "y",
		mods = "ALT",
		action = act.Multiple({ act.CopyMode("ClearSelectionMode"), act.ActivateCopyMode, act.ClearSelection }),
	},

	{
		key = "]",
		mods = "ALT",
		action = act.RotatePanes("CounterClockwise"),
	},

	{ key = "[", mods = "ALT", action = act.RotatePanes("Clockwise") },

  { key = "m", mods = "ALT|CTRL", action = wezterm.action.ToggleFullScreen },

	-- { key = "g", mods = "ALT|CTRL", action = act({ EmitEvent = "trigger-lazygit" }) },

	{
		mods = "ALT",
		key = "s",
		action = act({
			ActivateKeyTable = {
				name = "resize_pane",
				one_shot = false,
				timeout_milliseconds = 3000,
				replace_current = false,
			},
		}),
	},
	
}

M.zellij_keybinds = {
	{ key = "h", mods = "ALT", action=wezterm.action{SendString=""} },
	{ key = "l", mods = "ALT", action=wezterm.action{SendString=""} },
	{ key = "k", mods = "ALT", action=wezterm.action{SendString=""} },
	{ key = "j", mods = "ALT", action=wezterm.action{SendString=""} },

	{ key = "n", mods = "ALT|CTRL", action=wezterm.action{SendString="󰝜"} },
	{ key = "h", mods = "ALT|CTRL", action=wezterm.action{SendString="󰌥"} },
	{ key = "l", mods = "ALT|CTRL", action=wezterm.action{SendString="󰌒"}},

	{ key = "j", mods = "ALT|SHIFT", action=wezterm.action{SendString="󰅊"} },
	{ key = "l", mods = "ALT|SHIFT", action=wezterm.action{SendString="󰳹"} },

	{ key = "z", mods = "ALT", action=wezterm.action{SendString=""} },

	{ key = "x", mods = "ALT", action=wezterm.action{SendString=""} },
	{ key = "x", mods = "ALT|CTRL|SHIFT", action=wezterm.action{SendString="󰱝"} },

	{ key = "y", mods = "ALT|CTRL", action=wezterm.action{SendString=""} },

  { key = "m", mods = "ALT|CTRL", action = wezterm.action.TogglePaneZoomState },

	{ key = "[", mods = "ALT", action=wezterm.action{SendString=""} },
	{ key = "]", mods = "ALT", action=wezterm.action{SendString=""} },

	{ key = "f", mods = "ALT", action=wezterm.action{SendString="󰉧"} },

	{ key = "`", mods = "ALT", action=wezterm.action{SendString=""} },

	-- { key = "h", mods = "ALT|CTRL", action = act({ MoveTabRelative = -1 }) },
	-- { key = "l", mods = "ALT|CTRL", action = act({ MoveTabRelative = 1 }) },

  -- { key = "z", mods = "ALT", action = wezterm.action.TogglePaneZoomState},

	-- { key = "y", mods = "ALT", action = act.ActivateCopyMode },
	-- { key = "e", mods = "ALT", action = act({ EmitEvent = "trigger-nvim-with-scrollback" }) },

	-- { key = "p", mods = "ALT", action = act({ PasteFrom = "PrimarySelection" }) },

	-- { key = "g", mods = "ALT|CTRL", action = act({ EmitEvent = "trigger-lazygit" }) },
	
}

M.default_keybinds = {
  {key="LeftArrow", mods="OPT", action=wezterm.action{SendString="\x1bb"}},
  {key="RightArrow", mods="OPT", action=wezterm.action{SendString="\x1bf"}},

  {
      mods = "ALT",
      key = "Enter",
      action = wezterm.action_callback(function(win, pane)
        if (is_file_browser(pane)) then
           win:perform_action(act.SendKey({key="Enter", mods="ALT"}), pane)
        else
           win:perform_action(act.QuickSelect, pane)
        end
      end)
  },

	{ key = "/", mods = "ALT", action = act.Search("CurrentSelectionOrEmptyString") },

	-- { key = "p", mods = "ALT", action = act({ PasteFrom = "PrimarySelection" }) },
	{
      mods = "ALT",
      key = "p",
      action = wezterm.action_callback(function(win, pane)
        if (is_editor(pane)) then
           win:perform_action(act.SendKey({key="p", mods="ALT"}), pane)
        else
           win:perform_action(act({ PasteFrom = "PrimarySelection" }), pane)
        end
      end)
  },

	{ key = "c", mods = "CTRL|SHIFT", action = act({ CopyTo = "Clipboard" }) },
	{ key = "v", mods = "CTRL|SHIFT", action = act({ PasteFrom = "Clipboard" }) },

	{ key = "Insert", mods = "SHIFT", action = act({ PasteFrom = "PrimarySelection" }) },

	{ key = "=", mods = "CTRL", action = "ResetFontSize" },
	{ key = "+", mods = "CTRL|SHIFT", action = "IncreaseFontSize" },
	{ key = "-", mods = "CTRL", action = "DecreaseFontSize" },

	{ key = "PageUp", mods = "ALT", action = act({ ScrollByPage = -1 }) },
	{ key = "PageDown", mods = "ALT", action = act({ ScrollByPage = 1 }) },

	-- { key = "b", mods = "ALT", action = act({ ScrollByPage = -1 }) },
	-- { key = "f", mods = "ALT", action = act({ ScrollByPage = 1 }) },

	{ key = "1", mods = "ALT", action = "ReloadConfiguration" },
	{ key = "Escape", mods = "ALT", action = act({ EmitEvent = "toggle-tmux-keybinds" }) },

	-- { key = "a", mods = "ALT", action = wezterm.action.ShowLauncher },
	-- { key = " ", mods = "ALT", action = wezterm.action.ShowTabNavigator },
	{ key = "d", mods = "ALT|SHIFT", action = wezterm.action.ShowDebugOverlay },

	-- { key = "s", mods = "ALT", action = act.PaneSelect({
	-- 	alphabet = "1234567890",
	-- }) },
	{
		key = "r",
		mods = "ALT|CTRL",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			-- selene: allow(unused_variable)
			---@diagnostic disable-next-line: unused-local
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

}

function M.create_keybinds()
	if wezterm.GLOBAL.mode == nil then
		wezterm.GLOBAL.mode = "NORMAL"
	end

	mode = wezterm.GLOBAL.mode

	if mode == "ZELLIJ" then
		return utils.merge_lists(M.default_keybinds, M.zellij_keybinds)
	elseif mode == "NORMAL" then
		return utils.merge_lists(M.default_keybinds, M.tmux_keybinds)
	else 
		return M.default_keybinds
	end
  -- Log the current state before changes

	-- return M.default_keybinds
	-- return utils.merge_lists(M.default_keybinds, M.tmux_keybinds)
	-- return utils.merge_lists(M.default_keybinds, M.tmux_keybinds)
end

M.key_tables = {
	resize_pane = {
		{ key = "LeftArrow", action = act({ AdjustPaneSize = { "Left", 1 } }) },
		{ key = "h", action = act({ AdjustPaneSize = { "Left", 1 } }) },
		{ key = "RightArrow", action = act({ AdjustPaneSize = { "Right", 1 } }) },
		{ key = "l", action = act({ AdjustPaneSize = { "Right", 1 } }) },
		{ key = "UpArrow", action = act({ AdjustPaneSize = { "Up", 1 } }) },
		{ key = "k", action = act({ AdjustPaneSize = { "Up", 1 } }) },
		{ key = "DownArrow", action = act({ AdjustPaneSize = { "Down", 1 } }) },
		{ key = "j", action = act({ AdjustPaneSize = { "Down", 1 } }) },
		-- Cancel the mode by pressing escape
		{ key = "Escape", action = "PopKeyTable" },
	},
	copy_mode = {
		{
			key = "Escape",
			mods = "NONE",
			action = act.Multiple({
				act.ClearSelection,
				act.CopyMode("ClearPattern"),
				act.CopyMode("Close"),
			}),
		},
		{ key = "q", mods = "NONE", action = act.CopyMode("Close") },
		-- move cursor
		{ key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "UpArrow", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
		{ key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },
		-- move word
		{ key = "RightArrow", mods = "ALT", action = act.CopyMode("MoveForwardWord") },
		{ key = "f", mods = "ALT", action = act.CopyMode("MoveForwardWord") },
		{ key = "\t", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
		{ key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
		{ key = "LeftArrow", mods = "ALT", action = act.CopyMode("MoveBackwardWord") },
		{ key = "b", mods = "ALT", action = act.CopyMode("MoveBackwardWord") },
		{ key = "\t", mods = "SHIFT", action = act.CopyMode("MoveBackwardWord") },
		{ key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
		{
			key = "e",
			mods = "NONE",
			action = act({
				Multiple = {
					act.CopyMode("MoveRight"),
					act.CopyMode("MoveForwardWord"),
					act.CopyMode("MoveLeft"),
				},
			}),
		},
		-- move start/end
		{ key = "H", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLine") },
		{ key = "\n", mods = "NONE", action = act.CopyMode("MoveToStartOfNextLine") },
		{ key = "L", mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
		{ key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
		{ key = "e", mods = "CTRL", action = act.CopyMode("MoveToEndOfLineContent") },
		{ key = "m", mods = "ALT", action = act.CopyMode("MoveToStartOfLineContent") },
		{ key = "^", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
		{ key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
		{ key = "a", mods = "CTRL", action = act.CopyMode("MoveToStartOfLineContent") },
		-- select
		{ key = " ", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
		{ key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
		{
			key = "v",
			mods = "SHIFT",
			action = act({
				Multiple = {
					act.CopyMode("MoveToStartOfLineContent"),
					act.CopyMode({ SetSelectionMode = "Cell" }),
					act.CopyMode("MoveToEndOfLineContent"),
				},
			}),
		},

		-- copy
		{
			key = "y",
			mods = "NONE",
			action = act({
				Multiple = {
					act({ CopyTo = "ClipboardAndPrimarySelection" }),
					act.CopyMode("Close"),
				},
			}),
		},
		{
			key = "y",
			mods = "SHIFT",
			action = act({
				Multiple = {
					act.CopyMode({ SetSelectionMode = "Cell" }),
					act.CopyMode("MoveToEndOfLineContent"),
					act({ CopyTo = "ClipboardAndPrimarySelection" }),
					act.CopyMode("Close"),
				},
			}),
		},

		-- scroll
		{ key = "G", mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },
		{ key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
		{ key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
		-- { key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
		-- { key = "H", mods = "SHIFT", action = act.CopyMode("MoveToViewportTop") },
		{ key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
		{ key = "M", mods = "SHIFT", action = act.CopyMode("MoveToViewportMiddle") },
		-- { key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
		-- { key = "L", mods = "SHIFT", action = act.CopyMode("MoveToViewportBottom") },
		{ key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
		{ key = "O", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
		{ key = "O", mods = "SHIFT", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
		{ key = "u", mods = "CTRL", action = act.CopyMode("PageUp") },
		{ key = "d", mods = "CTRL", action = act.CopyMode("PageDown") },
		{ key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
		{ key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
		{
			key = "Enter",
			mods = "NONE",
			action = act.CopyMode("ClearSelectionMode"),
		},
		-- search
		{ key = "/", mods = "NONE", action = act.Search("CurrentSelectionOrEmptyString") },
		{
			key = "n",
			mods = "NONE",
			action = act.Multiple({
				act.CopyMode("NextMatch"),
				act.CopyMode("ClearSelectionMode"),
			}),
		},
		{
			key = "N",
			mods = "SHIFT",
			action = act.Multiple({
				act.CopyMode("PriorMatch"),
				act.CopyMode("ClearSelectionMode"),
			}),
		},
	},
	search_mode = {
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{
			key = "Enter",
			mods = "NONE",
			action = act.Multiple({
				act.CopyMode("ClearSelectionMode"),
				act.ActivateCopyMode,
			}),
		},
		-- { key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
		-- { key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
		-- { key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
		-- { key = "/", mods = "NONE", action = act.CopyMode("ClearPattern") },

		-- { key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
	},
}

M.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act({ CompleteSelection = "PrimarySelection" }),
	},
	{
		event = { Up = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = act({ CompleteSelection = "Clipboard" }),
	},
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = "OpenLinkAtMouseCursor",
	},
}




return M
