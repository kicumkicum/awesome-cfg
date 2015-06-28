--
-- Created by IntelliJ IDEA.
-- User: oleg
-- Date: 28.06.15
-- Time: 22:11
-- To change this template use File | Settings | File Templates.
--
local beautiful = require('beautiful')
local gears = require('gears')
local wallpaper = {}

wallpaper.init = function()
    if beautiful.wallpaper then
        for s = 1, screen.count() do
            gears.wallpaper.maximized(beautiful.wallpaper, s, true)
        end
    end
end

return wallpaper
