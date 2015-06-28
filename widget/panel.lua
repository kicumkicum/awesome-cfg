--
-- Created by IntelliJ IDEA.
-- User: oleg
-- Date: 28.06.15
-- Time: 20:33
-- To change this template use File | Settings | File Templates.
--
local awful = require('awful')
local menubar = require('menubar')
local wibox = require('wibox')


local panel = {}


panel.init = function(layouts)
	panel.createDisplay(layouts)
end

panel.createClock = function()
	return awful.widget.textclock()
end

panel.createTagList = function()
	local mytaglist = {}
	mytaglist.buttons = awful.util.table.join(
		awful.button({}, 1, awful.tag.viewonly),
		awful.button({modkey}, 1, awful.client.movetotag),
		awful.button({}, 3, awful.tag.viewtoggle)
	)
	return mytaglist
end


panel.createTaskList = function()
	local mytasklist = {}

	mytasklist.buttons = awful.util.table.join(
		awful.button({}, 1, function(c)
			if not (c == client.focus) then
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
		awful.button({}, 2, function(c)
			c:kill() --close window by scroll
		end),
		awful.button({}, 3, function()
			if instance then
				instance:hide()
				instance = nil
			else
				instance = awful.menu.clients({width = 250})
			end
		end)
	)
	return mytasklist
end


panel.createPromptBox = function()
	return awful.widget.prompt()
end


panel.createDisplay = function(layouts)
	menubar.utils.terminal = terminal -- Set the terminal for applications that require it
	local mytextclock = panel.createClock()
	local mytaglist = panel.createTagList()
	local mytasklist = panel.createTaskList()

	for screenIndex = 1, screen.count() do
		panel.createScreen(layouts, screenIndex, mytasklist, mytaglist, mytextclock)
	end
end


panel.createScreen = function(layouts, screenIndex, mytasklist, mytaglist, mytextclock)
	local mypromptbox = {}
	local mylayoutbox = {}
	local mywibox = {}
	
	-- Create a promptbox for each screen
	mypromptbox[screenIndex] = panel.createPromptBox()
	 
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	mylayoutbox[screenIndex] = awful.widget.layoutbox(screenIndex)
	mylayoutbox[screenIndex]:buttons(awful.util.table.join(
		awful.button({}, 1, function() awful.layout.inc(layouts, 1) end),
		awful.button({}, 3, function() awful.layout.inc(layouts, -1) end),
		awful.button({}, 4, function() awful.layout.inc(layouts, 1) end),
		awful.button({}, 5, function() awful.layout.inc(layouts, -1) end)))

	-- Create a taglist widget
	mytaglist[screenIndex] = awful.widget.taglist(screenIndex, awful.widget.taglist.filter.all, mytaglist.buttons)

	-- Create a tasklist widget
	mytasklist[screenIndex] = awful.widget.tasklist(screenIndex, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

	-- Create the wibox
	mywibox[screenIndex] = awful.wibox({
		position = 'top',
		screen = screenIndex
	})

	-- Widgets that are aligned to the left
	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(mytaglist[screenIndex])
	left_layout:add(mypromptbox[screenIndex])

	-- Widgets that are aligned to the right
	local right_layout = wibox.layout.fixed.horizontal()
	if (screenIndex == 1) then
		right_layout:add(wibox.widget.systray())
	end
	right_layout:add(mytextclock)
	right_layout:add(mylayoutbox[screenIndex])

	-- Now bring it all together (with the tasklist in the middle)
	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(mytasklist[screenIndex])
	layout:set_right(right_layout)

	mywibox[screenIndex]:set_widget(layout)
end

return panel
