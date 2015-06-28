modkey = 'Mod4'
terminal = 'x-terminal-emulator'
editor = 'sublime' -- os.getenv('EDITOR') or
editor_cmd = terminal .. ' -e ' .. editor

require('awful.autofocus')
require('wicked')

local awful = require('awful')
awful.rules = require('awful.rules')

local beautiful = require('beautiful')

popup = require('widget.popup')
local panel = require('widget.panel')
local wallpaper = require('widget.wallpaper')
local tag = require('rules.tag')
local keybinding = require('rules.keybinding')
local layout = require('rules.layout')
local clientHandler = require('handler.client')
local handler = require('handler')
--checkStartupError()
--bindErrorHandler()

beautiful.init('/home/oleg/.config/awesome/themes/zenburn/theme.lua')
local layouts = layout.init()
panel.init(layouts)
wallpaper.init()
tags = tag.init()

local keys = keybinding.init()
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

-- {{{ Signals
-- Signal function to execute when a new client appears.
--client.connect_signal('manage', handler.client.onManage)
client.connect_signal('manage', function(c, s)
	handler.client.onManage(c, s)
end)

client.connect_signal('focus', function(c) c.border_color = beautiful.border_focus end)
client.connect_signal('unfocus', function(c) c.border_color = beautiful.border_normal end)
-- }}}

function checkStartupError()
	if awesome.startup_errors then
		popup.error('awesome.startup_errors')
	end
end

function bindErrorHandler()
	local in_error = false
	awesome.connect_signal('debug::error', function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end

		in_error = true
		popup.error('', err)
		in_error = false
	end)
end
