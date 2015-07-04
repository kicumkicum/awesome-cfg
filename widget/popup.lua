--
-- Created by IntelliJ IDEA.
-- User: oleg
-- Date: 28.06.15
-- Time: 2:48
-- To change this template use File | Settings | File Templates.
--

local naughty = require('naughty')
local popup = {}

popup.error = function(text, title)
	if not title then
		title = 'error'
	end
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = title,
		text = text
	})
end

return popup
