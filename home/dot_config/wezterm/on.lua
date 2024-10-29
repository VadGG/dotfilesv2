local wezterm = require("wezterm")
local utils = require("utils")
local keybinds = require("keybinds")
local scheme = wezterm.get_builtin_color_schemes()["nord"]
local act = wezterm.action

local hx_bin_path = "/Users/vadimgagarin/.cargo/bin/hx"
local lazygit_bin_path = "/opt/homebrew/bin/lazygit"
-- local lazygit_bin_path = "/usr/people/gagarinv/dev/dotfiles/bin/centos/lazygit"

local function table_to_string(tbl, indent)
    if not indent then indent = 0 end
    local toprint = string.rep(" ", indent) .. "{\n"
    indent = indent + 2
    for k, v in pairs(tbl) do
        toprint = toprint .. string.rep(" ", indent)
        if type(k) == "number" then
            toprint = toprint .. "[" .. k .. "] = "
        elseif type(k) == "string" then
            toprint = toprint .. k .. " = "
        end
        if type(v) == "table" then
            toprint = toprint .. table_to_string(v, indent + 2) .. ",\n"
        else
            toprint = toprint .. tostring(v) .. ",\n"
        end
    end
    toprint = toprint .. string.rep(" ", indent - 2) .. "}"
    return toprint
end


-- 
---------------------------------------------------------------
--- wezterm on
---------------------------------------------------------------
-- SETTING TITLE
-- selene: allow(unused_variable)
-- ---@diagnostic disable-next-line: unused-local
-- local function create_tab_title(tab, tabs, panes, config, hover, max_width)
-- 	local user_title = tab.active_pane.user_vars.panetitle
-- 	if user_title ~= nil and #user_title > 0 then
-- 		return tab.tab_index + 1 .. ":" .. user_title
-- 	end
-- 	-- pane:get_foreground_process_info().status

-- 	local title = wezterm.truncate_right(utils.basename(tab.active_pane.foreground_process_name), max_width)
-- 	if title == "" then
-- 		local dir = string.gsub(tab.active_pane.title, "(.*[: ])(.*)]", "%2")
-- 		dir = utils.convert_useful_path(dir)
-- 		title = wezterm.truncate_right(dir, max_width)
-- 	end

-- 	local copy_mode, n = string.gsub(tab.active_pane.title, "(.+) mode: .*", "%1", 1)
-- 	if copy_mode == nil or n == 0 then
-- 		copy_mode = ""
-- 	else
-- 		copy_mode = copy_mode .. ": "
-- 	end
-- 	return copy_mode .. tab.tab_index + 1 .. ":" .. title
-- end

-- wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
-- 	local title = create_tab_title(tab, tabs, panes, config, hover, max_width)

-- 	-- selene: allow(undefined_variable)
-- 	local solid_left_arrow = utf8.char(0x2590)
-- 	-- selene: allow(undefined_variable)
-- 	local solid_right_arrow = utf8.char(0x258c)
-- 	-- https://github.com/wez/wezterm/issues/807
-- 	-- local edge_background = scheme.background
-- 	-- https://github.com/wez/wezterm/blob/61f01f6ed75a04d40af9ea49aa0afe91f08cb6bd/config/src/color.rs#L245
-- 	local edge_background = "#2e3440"
-- 	local background = scheme.ansi[1]
-- 	local foreground = scheme.ansi[5]

-- 	if tab.is_active then
-- 		background = scheme.brights[1]
-- 		foreground = scheme.brights[8]
-- 	elseif hover then
-- 		background = scheme.cursor_bg
-- 		foreground = scheme.cursor_fg
-- 	end
-- 	local edge_foreground = background

-- 	return {
-- 		{ Attribute = { Intensity = "Bold" } },
-- 		{ Background = { Color = edge_background } },
-- 		{ Foreground = { Color = edge_foreground } },
-- 		{ Text = solid_left_arrow },
-- 		{ Background = { Color = background } },
-- 		{ Foreground = { Color = foreground } },
-- 		{ Text = title },
-- 		{ Background = { Color = edge_background } },
-- 		{ Foreground = { Color = edge_foreground } },
-- 		{ Text = solid_right_arrow },
-- 		{ Attribute = { Intensity = "Normal" } },
-- 	}
-- end)

-- https://github.com/wez/wezterm/issues/1680
local function update_window_background(window, pane)
	local overrides = window:get_config_overrides() or {}
	-- If there's no foreground process, assume that we are "wezterm connect" or "wezterm ssh"
	-- and use a different background color
	-- if pane:get_foreground_process_name() == nil then
	-- 	-- overrides.colors = { background = "blue" }
	-- 	overrides.color_scheme = "Red Alert"
	-- end

	if overrides.color_scheme == nil then
		return
	end
	if pane:get_user_vars().production == "1" then
		overrides.color_scheme = "OneHalfDark"
	end
	window:set_config_overrides(overrides)
end

-- selene: allow(unused_variable)
---@diagnostic disable-next-line: unused-function, unused-local
local function update_tmux_style_tab(window, pane)
	local cwd_uri = pane:get_current_working_dir()
	---@diagnostic disable-next-line: unused-local
	local hostname, cwd = utils.split_from_url(cwd_uri)
	return {
		{ Attribute = { Underline = "Single" } },
		{ Attribute = { Italic = true } },
		{ Text = hostname },
	}
end

-- selene: allow(unused_variable)
---@diagnostic disable-next-line: unused-local
local function update_ssh_status(window, pane)
	local text = pane:get_domain_name()
	if text == "local" then
		text = ""
	end
	return {
		{ Attribute = { Italic = true } },
		{ Text = text .. " " },
	}
end

-- selene: allow(unused_variable)
---@diagnostic disable-next-line: unused-function, unused-local
local function display_ime_on_right_status(window, pane)
	local compose = window:composition_status()
	if compose then
		compose = "COMPOSING: " .. compose
	end
	window:set_right_status(compose)
end

-- selene: allow(unused_variable)
---@diagnostic disable-next-line: unused-local
local function display_copy_mode(window, pane)
	local name = window:active_key_table()
	if name then
		name = "Mode: " .. name
	end
	return { { Attribute = { Italic = false } }, { Text = name or "" } }
end

-- selene: allow(unused_variable)
---@diagnostic disable-next-line: unused-local
wezterm.on("toggle-tmux-keybinds", function(window, pane)
    local overrides = window:get_config_overrides() or {}
    local is_zellij_running = false

    local process_info = pane:get_foreground_process_info()
    if process_info and process_info.name and string.find(process_info.name, "zellij") then
        is_zellij_running = true
    end

		if wezterm.GLOBAL.mode == nil then
			wezterm.GLOBAL.mode = "NORMAL"
		end

		mode = wezterm.GLOBAL.mode

    -- Log the current state before changes
    wezterm.log_info("Current overrides keys count: " .. (overrides.keys and #overrides.keys or "nil"))

    if mode == "NORMAL" then
        if is_zellij_running then
            -- overrides.window_background_opacity = 0.95
            -- overrides.enable_tab_bar = false
            mode = "ZELLIJ"
        else
            -- overrides.window_background_opacity = 0.55
            -- overrides.enable_tab_bar = false
            mode = "LOCKED"
        end
    else
        -- overrides.window_background_opacity = 1
        -- overrides.enable_tab_bar = true
        mode = "NORMAL"
    end

    wezterm.GLOBAL.mode = mode
    overrides.keys = keybinds.create_keybinds()

    window:set_config_overrides(overrides)
end)

wezterm.on('window-config-reloaded', function(window, pane)
  window:toast_notification('wezterm', 'configuration reloaded!', nil, 4000)
end)

local io = require("io")
local os = require("os")

wezterm.on("trigger-nvim-with-scrollback", function(window, pane)
	local scrollback = pane:get_lines_as_text()
	local name = os.tmpname()
	local f = io.open(name, "w+")
	if f == nil then
		return
	end
	f:write(scrollback)
	f:flush()
	f:close()
	window:perform_action(
		act({
			SpawnCommandInNewTab = {
				-- args = { os.getenv("HOME") .. "/.local/share/zsh/zinit/polaris/bin/nvim", name },
				-- args = { "vim", "-c", "set number", "-c", "set clipboard=unnamed", name },
				args = { hx_bin_path,name },
			},
		}),
		pane
	)
	wezterm.sleep_ms(1000)
	os.remove(name)
end)


