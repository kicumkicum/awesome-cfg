require('awful.autofocus')
require('wicked')

local awful = require('awful')
awful.rules = require('awful.rules')

local beautiful = require('beautiful')
local gears = require('gears')
local menubar = require('menubar')
local wibox = require('wibox')

local popup = require('widget.popup')
local tag = require('rules.tag')
local keybinding = require('rules.keybinding')
local layout = require('rules.layout')

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    popup.error()
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal('debug::error', function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
            return
        end

		in_error = true
		popup.error()
		in_error = false
	end)
end
-- }}}

beautiful.init('/home/oleg/.config/awesome/themes/zenburn/theme.lua')
terminal = 'x-terminal-emulator'
editor = 'sublime' -- os.getenv('EDITOR') or
editor_cmd = terminal .. ' -e ' .. editor
modkey = 'Mod4'

local layouts = layout.init()

-- {{{ Wallpaper
if beautiful.wallpaper then
	for s = 1, screen.count() do
		gears.wallpaper.maximized(beautiful.wallpaper, s, true)
	end
end
-- }}}

tags = tag.init()

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
	{ 'manual', terminal .. ' -e man awesome' },
	{ 'edit config', editor_cmd .. ' ' .. awesome.conffile },
	{ 'restart', awesome.restart },
	{ 'quit', awesome.quit }
}

mymainmenu = awful.menu({
    items = {{
        'awesome',
        myawesomemenu,
        beautiful.awesome_icon
    }}
})

mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = mymainmenu
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
						awful.button({ }, 1, awful.tag.viewonly),
						awful.button({ modkey }, 1, awful.client.movetotag),
						awful.button({ }, 3, awful.tag.viewtoggle)
						--awful.button({ modkey }, 3, awful.client.toggletag)--,
						--awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
						--awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
					)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
					awful.button({ }, 1, function(c)
											if c == client.focus then
												-- c.minimized = true
											else
												-- Without this, the following
												-- :isvisible() makes no sense
												c.minimized = false
												if not c:isvisible() then
													awful.tag.viewonly(c:tags()[1])
												end
												-- This will also un-minimize
												-- the client, if needed
												client.focus = c
												c:raise()
											end
										end),
					awful.button({ }, 2, function(c) 
											c:kill() --close window by scroll
										end),
					awful.button({ }, 3, function()
											if instance then
												instance:hide()
												instance = nil
											else
												instance = awful.menu.clients({width = 250})
											end
										end)--,
					--awful.button({ }, 4, function()
						--					awful.client.focus.byidx(1)
						--					if client.focus then client.focus:raise() end
						--				end),
					--awful.button({ }, 5, function()
						--					awful.client.focus.byidx(-1)
						--					if client.focus then client.focus:raise() end
						--				end)
									)

for s = 1, screen.count() do
	-- Create a promptbox for each screen
	mypromptbox[s] = awful.widget.prompt()
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	mylayoutbox[s] = awful.widget.layoutbox(s)
	mylayoutbox[s]:buttons(awful.util.table.join(
							awful.button({}, 1, function() awful.layout.inc(layouts, 1) end),
							awful.button({}, 3, function() awful.layout.inc(layouts, -1) end),
							awful.button({}, 4, function() awful.layout.inc(layouts, 1) end),
							awful.button({}, 5, function() awful.layout.inc(layouts, -1) end)))
	-- Create a taglist widget
	mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

	-- Create a tasklist widget
	mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

	-- Create the wibox
	mywibox[s] = awful.wibox({
        position = 'top',
        screen = s
    })

	-- Widgets that are aligned to the left
	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(mylauncher)
	left_layout:add(mytaglist[s])
	left_layout:add(mypromptbox[s])

	-- Widgets that are aligned to the right
	local right_layout = wibox.layout.fixed.horizontal()
	if (s == 1) then 
		right_layout:add(wibox.widget.systray())
	end
	right_layout:add(mytextclock)
	right_layout:add(mylayoutbox[s])

	-- Now bring it all together (with the tasklist in the middle)
	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(mytasklist[s])
	layout:set_right(right_layout)

	mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
--root.buttons(awful.util.table.join(
--	awful.button({ }, 3, function() mymainmenu:toggle() end),
--	awful.button({ }, 4, awful.tag.viewnext),
--	awful.button({ }, 5, awful.tag.viewprev)
--))
-- }}}

keybinding.init()

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
client.connect_signal('manage', function(c, startup)
	-- Enable sloppy focus
--	c:connect_signal('mouse::enter', function(c)
 --	if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
	--		and awful.client.focus.filter(c) then
	--	client.focus = c
		--end
	--end)

	if not startup then
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		-- awful.client.setslave(c)

		-- Put windows in a smart way, only if they does not set an initial position.
		if not c.size_hints.user_position and not c.size_hints.program_position then
			awful.placement.no_overlap(c)
			awful.placement.no_offscreen(c)
		end
	end

	local titlebars_enabled = false
	if titlebars_enabled and (c.type == 'normal' or c.type == 'dialog') then
		-- buttons for the titlebar
		local buttons = awful.util.table.join(
				awful.button({ }, 1, function()
					client.focus = c
					c:raise()
					awful.mouse.client.move(c)
				end),
				awful.button({ }, 3, function()
					client.focus = c
					c:raise()
					awful.mouse.client.resize(c)
				end)
				)

		-- Widgets that are aligned to the left
		local left_layout = wibox.layout.fixed.horizontal()
		left_layout:add(awful.titlebar.widget.iconwidget(c))
		left_layout:buttons(buttons)

		-- Widgets that are aligned to the right
		local right_layout = wibox.layout.fixed.horizontal()
		right_layout:add(awful.titlebar.widget.floatingbutton(c))
		right_layout:add(awful.titlebar.widget.maximizedbutton(c))
		right_layout:add(awful.titlebar.widget.stickybutton(c))
		right_layout:add(awful.titlebar.widget.ontopbutton(c))
		right_layout:add(awful.titlebar.widget.closebutton(c))

		-- The title goes in the middle
		local middle_layout = wibox.layout.flex.horizontal()
		local title = awful.titlebar.widget.titlewidget(c)
		title:set_align('center')
		middle_layout:add(title)
		middle_layout:buttons(buttons)

		-- Now bring it all together
		local layout = wibox.layout.align.horizontal()
		layout:set_left(left_layout)
		layout:set_right(right_layout)
		layout:set_middle(middle_layout)

		awful.titlebar(c):set_widget(layout)
	end
end)

client.connect_signal('focus', function(c) 
									c.border_color = beautiful.border_focus
								end)
client.connect_signal('unfocus', function(c)
									c.border_color = beautiful.border_normal
								end)
-- }}}
