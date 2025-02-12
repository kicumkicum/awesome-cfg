--
-- Created by IntelliJ IDEA.
-- User: oleg
-- Date: 28.06.15
-- Time: 2:46
-- To change this template use File | Settings | File Templates.
--
local awful = require('awful')
local menubar = require("menubar")
local keybinging = {}

keybinging.init = function(layouts)
	local globalKeys = keybinging.global(layouts)
	local client = keybinging.client()
	return {
		globalKeys = globalKeys,
		client = client
	}
end


keybinging.global = function(layouts)
	local globalBinding

	keybinging._initTasks(layouts)
	globalBinding = awful.util.table.join(
		keybinging.tasks.volume.up,
		keybinging.tasks.volume.down,
		keybinging.tasks.volume.mute,

		keybinging.tasks.screen.nextTag,
		keybinging.tasks.screen.prevTag,
		keybinging.tasks.screen.toggleTag,
		keybinging.tasks.screen.goToFirst,
		keybinging.tasks.screen.goToSecond,

		keybinging.tasks.tag.nextClientFocus,
		keybinging.tasks.tag.prevClientFocus,
		keybinging.tasks.tag.toggleClientFocus,
		keybinging.tasks.tag.nextClientPosition,
		keybinging.tasks.tag.prevClientPosition,
		keybinging.tasks.tag.changeLayout,
		keybinging.tasks.tag.nextLayout,
		keybinging.tasks.tag.prevLayout,

		keybinging.tasks.client.unminimaze,
		keybinging.tasks.client.larger,
		keybinging.tasks.client.less,

		keybinging.tasks.action.runCommand,
		keybinging.tasks.action.runApplication,
		keybinging.tasks.action.runLuaCode,
		keybinging.tasks.action.runTerminal,
		keybinging.tasks.action.restartAwesome,
		keybinging.tasks.action.quitAwesome,

		keybinging.tasks.action.printScreen
	)

	-- Bind all key numbers to tags.
	-- Be careful: we use keycodes to make it works on any keyboard layout.
	-- This should map on the top row of your keyboard, usually 1 to 9.
	for i = 1, 9 do
		globalBinding = awful.util.table.join(globalBinding,
			awful.key({modkey}, '#' .. i + 9, function()
				local screen = mouse.screen
				local tag = awful.tag.gettags(screen)[i]
				if tag then
					awful.tag.viewonly(tag)
				end
			end),
-- 			awful.key({modkey, 'Mod1'}, '#' .. i + 9, function()
-- 				if i < 5 then
-- 					local screen = mouse.screen
-- 					local tag = awful.tag.gettags(screen)[i + 4]
-- 					if tag then
-- 						awful.tag.viewonly(tag)
-- 					end
-- 				end
-- 			end),
			awful.key({modkey, 'Control'}, '#' .. i + 9, function()
				local screen = mouse.screen
				local tag = awful.tag.gettags(screen)[i]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end),
			awful.key({modkey, 'Shift'}, '#' .. i + 9, function()
				local tag = awful.tag.gettags(client.focus.screen)[i]
				if client.focus and tag then
					awful.client.movetotag(tag)
				end
			end),
			awful.key({modkey, 'Control', 'Shift'}, '#' .. i + 9, function()
				local tag = awful.tag.gettags(client.focus.screen)[i]
				if client.focus and tag then
					awful.client.toggletag(tag)
				end
			end))
	end

    globalBinding = awful.util.table.join(globalBinding,
        awful.key({'Mod1'}, '#' .. 3 + 9, function()
            local screen = mouse.screen
            local tag = awful.tag.gettags(screen)[9]
            if tag then
                awful.tag.viewonly(tag)
            end
        end)
    )

	--------------------------------------------------------
	--------------switch tags with MOD+NUM_PAD--------------
	--------------------------------------------------------
	for i = 1, 3 do
		globalBinding = awful.util.table.join(globalBinding,
			awful.key({modkey}, '#' .. i + 86, function()
				local screen = mouse.screen
				local tag = awful.tag.gettags(screen)[i]
				if tag then
					awful.tag.viewonly(tag)
				end
			end))
	end

	for i = 4, 6 do
		globalBinding = awful.util.table.join(globalBinding,
			awful.key({modkey}, '#' .. i + 79, function()
				local screen = mouse.screen
				local tag = awful.tag.gettags(screen)[i]
				if tag then
					awful.tag.viewonly(tag)
				end
			end))
	end

	for i = 7, 9 do
		globalBinding = awful.util.table.join(globalBinding,
			awful.key({modkey}, '#' .. i + 72, function()
				local screen = mouse.screen
				local tag = awful.tag.gettags(screen)[i]
				if tag then
					awful.tag.viewonly(tag)
				end
			end))
	end

	return globalBinding
end


keybinging.client = function()
	local result = {}
	result.clientKeys = awful.util.table.join(
		awful.key({modkey}, 'f', function(c) c.fullscreen = not c.fullscreen end),
		awful.key({modkey, 'Control'}, '#9', function(c) c:kill()						end),
		awful.key({modkey, 'Control'}, 'space', awful.client.floating.toggle					),
		awful.key({modkey, 'Control'}, 'Return', function(c) c:swap(awful.client.getmaster()) end),
		--awful.key({modkey}, 'o',	awful.client.movetoscreen						),
		awful.key({modkey}, 't', function(c) c.ontop = not c.ontop			end),
		awful.key({modkey}, 'n', function(c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end),
		awful.key({modkey}, 'm', function(c)
			c.maximized_horizontal = not c.maximized_horizontal
			c.maximized_vertical	= not c.maximized_vertical
		end)
	)

	result.clientButtons = awful.util.table.join(
		awful.button({}, 1, function(c) client.focus = c; c:raise() end),
		awful.button({modkey}, 1, function() awful.mouse.client.move() end),
		awful.button({}, 2, function(c) client.focus = c; c:raise() end),
		awful.button({modkey}, 3, awful.mouse.client.resize)),
		awful.button({}, 3, function(c) client.focus = c; c:raise() end)
	return result
end


keybinging._initTasks = function(layouts)
	keybinging.tasks = {
		volume = {
			up = awful.key({}, 'XF86AudioRaiseVolume', function() awful.util.spawn('amixer set Master 2%+') end),
			down = awful.key({}, 'XF86AudioLowerVolume', function() awful.util.spawn('amixer set Master 2%-') end),
			mute = awful.key({}, 'XF86AudioMute', function() awful.util.spawn('amixer -D pulse set Master 1+ toggle') end)
		},
		client = {
			moveToScreen = awful.key({modkey, 'Control'}, 'm', awful.client.movetoscreen),
			unminimaze = awful.key({modkey, 'Control'}, 'n', awful.client.restore),
			larger = awful.key({modkey}, 'l', function() awful.tag.incmwfact(0.05) end),
			less = awful.key({modkey}, 'h', function() awful.tag.incmwfact(-0.05) end),

		},
		screen = {
			nextTag = awful.key({modkey}, 'Left',	awful.tag.viewprev),
			prevTag = awful.key({modkey}, 'Right', awful.tag.viewnext),
			toggleTag = awful.key({modkey}, '#49', awful.tag.history.restore),-- '~'
			goToFirst = awful.key({modkey, 'Control'}, 'h', function() awful.screen.focus(1) end),
			goToSecond = awful.key({modkey, 'Control'}, 's', function() awful.screen.focus(2) end),
		},
		tag = {
			nextClientPosition = awful.key({modkey, 'Shift'}, 'j', function() awful.client.swap.byidx(1) end),
			prevClientPosition = awful.key({modkey, 'Shift'}, 'k', function() awful.client.swap.byidx(-1) end),
			nextLayout = awful.key({modkey}, 'space', function() awful.layout.inc(layouts, 1) end),
			prevLayout = awful.key({modkey, 'Shift'}, 'space', function() awful.layout.inc(layouts, -1) end),

			nextClientFocus = awful.key({modkey}, 'j', function()
				awful.client.focus.byidx( 1)
				if client.focus then
					client.focus:raise()
				end
			end),

			prevClientFocus = awful.key({modkey}, 'k', function()
				awful.client.focus.byidx(-1)
				if client.focus then
					client.focus:raise()
				end
			end),

			toggleClientFocus = awful.key({modkey}, 'Tab', function()
				awful.client.focus.history.previous()
				if client.focus then
					client.focus:raise()
				end
			end)

			--      TODO разобраться что делают эти хоткеи
			--		awful.key({modkey}, 'l', function() awful.tag.incmwfact( 0.05)	end),
			--		awful.key({modkey}, 'h', function() awful.tag.incmwfact(-0.05)	end),
			--		awful.key({modkey, 'Control'}, 'j', function() awful.screen.focus_relative(1) end),
			--		awful.key({modkey, 'Control'}, 'k', function() awful.screen.focus_relative(-1) end),
			--		awful.key({modkey}, 'u', awful.client.urgent.jumpto),
			--		awful.key({modkey, 'Shift'}, 'h', function() awful.tag.incnmaster( 1)	end),
			--		awful.key({modkey, 'Shift'}, 'l', function() awful.tag.incnmaster(-1)	end),
			--		awful.key({modkey, 'Control'}, 'h', function() awful.tag.incncol( 1)		end),
			--		awful.key({modkey, 'Control'}, 'l', function() awful.tag.incncol(-1)		end)
		},
		action = {
			runTerminal = awful.key({modkey}, 'Return', function()
				awful.util.spawn(terminal)
			end),
			restartAwesome = awful.key({modkey, 'Control'}, 'r', awesome.restart),
-- 			quitAwesome = awful.key({modkey, 'Shift'}, 'q', awesome.quit),
			runCommand = awful.key({modkey}, 'r', function() mypromptbox[1]:run() end), --mypromptbox[mouse.screen]:run()mouse.screen
			runApplication = awful.key({modkey}, 'p', function() menubar.show() end),

			runLuaCode = awful.key({modkey}, 'x', function()
				awful.prompt.run({prompt = 'Run Lua code: '},
					mypromptbox[mouse.screen].widget,
					awful.util.eval,
					nil,
					awful.util.getdir('cache') .. '/history_eval')
			end),
            printScreen = awful.key({ }, "Print", function () awful.util.spawn("mate-screenshot") end),
		}
	}
end


return keybinging
