modkey = 'Mod4'
terminal = 'x-terminal-emulator'
editor = 'sublime' -- os.getenv('EDITOR') or
editor_cmd = terminal .. ' -e ' .. editor

require('awful.autofocus')
--require('vicious')

local awful = require('awful')
awful.rules = require('awful.rules')

local beautiful = require('beautiful')
local dysplay = require('widget.display')
local wallpaper = require('widget.wallpaper')
local tag = require('rules.tag')
local handler = require('handler')

local layout = require('rules.layout')
local layouts = layout.init()

local keybinding = require('rules.keybinding')

handler.error.init()
beautiful.init('/home/oleg/.config/awesome/themes/zenburn/theme.lua')
dysplay.init(layouts)
wallpaper.init()
tags = tag.init()

local keys = keybinding.init(layouts)
root.keys(keys.globalKeys)
local clientkeys = keys.client.clientKeys
local clientbuttons = keys.client.clientButtons

-- {{{ Rules
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			keys = clientkeys,
			buttons = clientbuttons
		}
	}
}
-- }}}

client.connect_signal('manage', handler.client.onManage)
client.connect_signal('focus', function(c) c.border_color = beautiful.border_focus end)
client.connect_signal('unfocus', function(c) c.border_color = beautiful.border_normal end)
