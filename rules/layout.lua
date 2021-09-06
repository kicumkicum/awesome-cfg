--
-- Created by IntelliJ IDEA.
-- User: oleg
-- Date: 28.06.15
-- Time: 3:07
-- To change this template use File | Settings | File Templates.
--
local awful = require('awful')
local layout = {}

layout.init = function()
    -- Table of layouts to cover with awful.layout.inc, order matters.
    local layouts = {
        awful.layout.suit.tile,
        awful.layout.suit.tile.top,
        awful.layout.suit.tile.left,
        awful.layout.suit.max,
        awful.layout.suit.magnifier,
        awful.layout.suit.floating
    }

    return layouts
end

return layout
