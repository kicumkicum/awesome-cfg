modkey = 'Mod4'
terminal = 'x-terminal-emulator'
editor = 'sublime' -- os.getenv('EDITOR') or
editor_cmd = terminal .. ' -e ' .. editor

require('awful.autofocus')
--require('vicious')

local os = require('os')
local awful = require('awful')
awful.rules = require('awful.rules')

local beautiful = require('beautiful')
local display = require('widget.display')
local wallpaper = require('widget.wallpaper')
local tag = require('rules.tag')
local handler = require('handler')

local layout = require('rules.layout')
local keybinding = require('rules.keybinding')

local HOME_PROFILE = "oleg"
local WORK_PROFILE = "akioo"

local USER = os.getenv('USER')

local layouts = layout.init()
handler.error.init()

if USER == HOME_PROFILE then
	beautiful.init('/home/oleg/.config/awesome/themes/zenburn/theme.lua')
else
	beautiful.init('/usr/share/awesome/themes/sky/theme.lua')
end

display.init(layouts)
wallpaper.init()

tags = tag.init()

local keys = keybinding.init(layouts)
root.keys(keys.globalKeys)

local client_keys = keys.client.clientKeys
local client_buttons = keys.client.clientButtons

-- {{{ Rules
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			keys = client_keys,
			buttons = client_buttons
		}
	}
}
-- }}}

client.connect_signal('manage', handler.client.onManage)
client.connect_signal('focus', function(c) c.border_color = beautiful.border_focus end)
client.connect_signal('unfocus', function(c) c.border_color = beautiful.border_normal end)
