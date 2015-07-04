--
-- Created by IntelliJ IDEA.
-- User: oleg
-- Date: 29.06.15
-- Time: 3:14
-- To change this template use File | Settings | File Templates.
--
local awful = require('awful')
local wibox = require('wibox')
local screen = {}

screen.init = function(screenIndex, panel, layouts)
    local mytasklist = panel.taskList
    local mytaglist = panel.tagList
    local mytextclock = panel.textClock

    mypromptbox = {}-- todo make local
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

return screen

