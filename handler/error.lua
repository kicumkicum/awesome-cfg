--
-- Created by IntelliJ IDEA.
-- User: oleg
-- Date: 29.06.15
-- Time: 2:57
-- To change this template use File | Settings | File Templates.
--
local popup = require('widget.popup')
local error = {}

error.init = function()
	if awesome.startup_errors then
		popup.error('awesome.startup_errors')
	end

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

return error
