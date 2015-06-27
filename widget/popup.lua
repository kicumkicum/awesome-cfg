--
-- Created by IntelliJ IDEA.
-- User: oleg
-- Date: 28.06.15
-- Time: 2:48
-- To change this template use File | Settings | File Templates.
--

local naughty = require('naughty')
local popup = {}

popup.error = function()
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = 'Oops, there were errors during startup!',
        text = 'awesome.startup_errors'
    })
end

return popup
