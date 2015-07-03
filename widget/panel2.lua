--
-- Created by IntelliJ IDEA.
-- User: oleg
-- Date: 03.07.15
-- Time: 1:43
-- To change this template use File | Settings | File Templates.
--
local awful = require('awful')



local panel = {}

panel.init = function()
    local textClock = panel.createClock()
    local tagList = panel.createTagList()
    local taskList = panel.createTaskList()

    return {
        textClock = textClock,
        tagList = tagList,
        taskList = taskList
    }
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




return panel

