--
-- Created by IntelliJ IDEA.
-- User: oleg
-- Date: 29.06.15
-- Time: 3:13
-- To change this template use File | Settings | File Templates.
--
local display = {}

display.init = function(layouts)

    local menubar = require('menubar')
    local panel = require('widget.panel2')
    local screenW = require('widget.screen')
    menubar.utils.terminal = terminal -- Set the terminal for applications that require it

    local punelResult = panel.init()
    punelResult.createPromptBox = panel.createPromptBox

    display.screen = {}
    for screenIndex = 1, screen.count() do
        display.screen[screenIndex] = screenW.init(screenIndex, punelResult, layouts)
    end

    return display
end

return display

