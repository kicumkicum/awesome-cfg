-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

local revelation = require("revelation")

-- Load Debian menu entries
local debian_menu = require("debian_menu")

--Tyrannical—A simple tag managment engine for Awesome
--git clone https://github.com/Elv13	yrannical.git
local tyrannical = require("tyrannical")

require("wicked")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({	preset = naughty.config.presets.critical,
						title = "Oops, there were errors during startup!",
					 	text = awesome.startup_errors 
					})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({ preset = naughty.config.presets.critical,
						 title = "Oops, an error happened!",
						 text = err })
		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/oleg/.config/awesome	hemes/zenburn	heme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = "sublime" -- os.getenv("EDITOR") or
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.tile.top,
	awful.layout.suit.tile.left,
	awful.layout.suit.max,
	awful.layout.suit.magnifier,
	awful.layout.suit.floating
	--awful.layout.suit.tile.bottom,
	--awful.layout.suit.fair,
	--awful.layout.suit.fair.horizontal,
	--awful.layout.suit.spiral,
	--awful.layout.suit.spiral.dwindle,
	--awful.layout.suit.max.fullscreen,
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
	for s = 1, screen.count() do
		gears.wallpaper.maximized(beautiful.wallpaper, s, true)
	end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
tyrannical.tags = {
	{
		name		= "console",			  -- Call the tag "Term"
		init		= true,				   -- Load the tag on startup
		exclusive   = true,				   -- Refuse any other type of clients (by classes)
		screen		= {1, 2},				  -- Create this tag on screen 1 and screen 2
		layout		= awful.layout.suit.tile, -- Use the tile layout
		instance	= {"dev", "ops"},		 -- Accept the following instances. This takes precedence over 'class'
		class		= { --Accept the following classes, refuse everything else (because of "exclusive=true")
			"xterm", "urxvt", "aterm", "URxvt", "XTerm", "konsole", "terminator", "gnome-terminal"
		}
	}, {
		name		= "work",
		init		= true,
		exclusive   = true,
	  --icon		= "~net.png",				 -- Use this icon for the tag (uncomment with a real path)
		screen		= screen.count()>1 and 2 or 1,-- Setup on screen 2 if there is more than 1 screen, else on screen 1
		layout		= awful.layout.suit.max,	  -- Use the max layout
		class 		= {
			"jetbrains-webstorm"
		}
	}, {
		name 		= "www",
		init		= true,
		exclusive   = true,
		screen		= 1,
		layout		= awful.layout.suit.tile,
		exec_once	= {"dolphin"}, --When the tag is accessed for the first time, execute this command
		class		= {
			"Opera"		 , "Firefox"		, "Rekonq"	, "Dillo"		, "Arora",
			"Chromium"	  , "nightly"		, "Google-chrome" , "Chrome"	 
		}
	}, {
		name 		= "im",
		init		= true,
		exclusive   = true,
		screen 		= 1,
		clone_on	= 2, -- Create a single instance of this tag on screen 1, but also show it on screen 2
						 -- The tag can be used on both screen, but only one at once
		layout	= awful.layout.suit.max						  ,
		class 		= { 
			"Skype"
		}
	}, {
		name		= "files",
		init		= true, -- This tag wont be created at startup, but will be when one of the
							 -- client in the "class" section will start. It will be created on
							 -- the client startup screen
		exclusive   = true,
		layout 		= awful.layout.suit.max,
		class 		= {
			"Thunar",	"Nautilus"
		}			
	}, {
		name		= "media",
		init		= true, -- This tag wont be created at startup, but will be when one of the
							 -- client in the "class" section will start. It will be created on
							 -- the client startup screen
		exclusive   = true,
		layout 		= awful.layout.suit.max,
		class 		= {
			"Assistant",	"Okular",	"Evince",	"EPDFviewer",	"xpdf",
		"Xpdf"
		}
	}, {
		name		= "vm",
		init		= true, -- This tag wont be created at startup, but will be when one of the
							-- client in the "class" section will start. It will be created on
							-- the client startup screen
		exclusive   = true,
		layout		= awful.layout.suit.max,
		class	  	= {
			"VirtualBox"
		}
	}, {
		name		= "other",
		init		= true, -- This tag wont be created at startup, but will be when one of the
							 -- client in the "class" section will start. It will be created on
							 -- the client startup screen
		exclusive   = true,
		layout	  = awful.layout.suit.max,
		class	   = {
			"Assistant"	 , "Okular"		 , "Evince"	, "EPDFviewer"   , "xpdf",
			"Xpdf"
		}
	}
}

-- Ignore the tag "exclusive" property for the following clients (matched by classes)
tyrannical.properties.intrusive = {
	"ksnapshot"	 , "pinentry"	   , "gtksu"	 , "kcalc"		, "xcalc"			   ,
	"feh"		   , "Gradient editor", "About KDE" , "Paste Special", "Background color"	,
	"kcolorchooser" , "plasmoidviewer" , "Xephyr"	, "kruler"	   , "plasmaengineexplorer",
}

-- Ignore the tiled layout for the matching clients
tyrannical.properties.floating = {
	"MPlayer"	  , "pinentry"		, "ksnapshot"  , "pinentry"	 , "gtksu"		  ,
	"xine"		 , "feh"			 , "kmix"	   , "kcalc"		, "xcalc"		  ,
	"yakuake"	  , "Select Color$"   , "kruler"	 , "kcolorchooser", "Paste Special"  ,
	"New Form"	 , "Insert Picture"  , "kcharselect", "mythfrontend" , "plasmoidviewer" 
}

-- Make the matching clients (by classes) on top of the default layout
tyrannical.properties.ontop = {
	"Xephyr"	   , "ksnapshot"	   , "kruler"
}

-- Force the matching clients (by classes) to be centered on the screen on init
tyrannical.properties.centered = {
	"kcalc"
}

tyrannical.settings.block_children_focus_stealing = true --Block popups ()
tyrannical.settings.group_children = true --Force popups/dialogs to have the same tags as the parent client

-- }}}

tags = awful.tag.gettags()

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon }--,
									--{ "Debian", debian_menu.Debian },
									--{ "open terminal", terminal }
								  }
						})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
									 menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
						awful.button({ }, 1, awful.tag.viewonly),
						awful.button({ modkey }, 1, awful.client.movetotag),
						awful.button({ }, 3, awful.tag.viewtoggle)
						--awful.button({ modkey }, 3, awful.client.toggletag)--,
						--awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
						--awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
					)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
					 awful.button({ }, 1, function (c)
											  if c == client.focus then
												 -- c.minimized = true
											  else
												  -- Without this, the following
												  -- :isvisible() makes no sense
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
					 awful.button({ }, 2, function (c) 
					 						  c:kill() --close window by scroll
					 					  end),
					 awful.button({ }, 3, function ()
											  if instance then
												  instance:hide()
												  instance = nil
											  else
												  instance = awful.menu.clients({ width=250 })
											  end
										  end)--,
					 --awful.button({ }, 4, function ()
						--					  awful.client.focus.byidx(1)
						--					  if client.focus then client.focus:raise() end
						--				  end),
					 --awful.button({ }, 5, function ()
						--					  awful.client.focus.byidx(-1)
						--					  if client.focus then client.focus:raise() end
						--				  end)
									)

for s = 1, screen.count() do
	-- Create a promptbox for each screen
	mypromptbox[s] = awful.widget.prompt()
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	mylayoutbox[s] = awful.widget.layoutbox(s)
	mylayoutbox[s]:buttons(awful.util.table.join(
						   awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
						   awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
						   awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
						   awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
	-- Create a taglist widget
	mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

	-- Create a tasklist widget
	mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

	-- Create the wibox
	mywibox[s] = awful.wibox({ position = "top", screen = s })

	-- Widgets that are aligned to the left
	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(mylauncher)
	left_layout:add(mytaglist[s])
	left_layout:add(mypromptbox[s])

	-- Widgets that are aligned to the right
	local right_layout = wibox.layout.fixed.horizontal()
	if (s == 1) then 
		right_layout:add(wibox.widget.systray()) 
	end
	right_layout:add(mytextclock)
	right_layout:add(mylayoutbox[s])

	-- Now bring it all together (with the tasklist in the middle)
	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(mytasklist[s])
	layout:set_right(right_layout)

	mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
--root.buttons(awful.util.table.join(
--	awful.button({ }, 3, function () mymainmenu:toggle() end),
--	awful.button({ }, 4, awful.tag.viewnext),
--	awful.button({ }, 5, awful.tag.viewprev)
--))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
	awful.key({ modkey,			}, "Left",   awful.tag.viewprev	   ),
	awful.key({ modkey,			}, "Right",  awful.tag.viewnext	   ),
	awful.key({ modkey,			}, "#49", awful.tag.history.restore), -- "~"
	-- awful.key({	modkey,			}, "e",  	revelation.revelation	,		   ),

	awful.key({ modkey, "Control"}, "h", function () awful.screen.focus(1) end),
	awful.key({ modkey, "Control"}, "s", function () awful.screen.focus(2) end),

	awful.key({ modkey, "Control"}, "m", awful.client.movetoscreen),

	awful.key({ modkey,		   	}, "j",	function ()
											awful.client.focus.byidx( 1)
											if client.focus then client.focus:raise() end
										end
	),
	awful.key({ modkey, 	   }, "k",	function ()
											awful.client.focus.byidx(-1)
											if client.focus then client.focus:raise() end
										end
	),
	awful.key({ modkey,		   }, "w", function () mymainmenu:show() end),

	-- Layout manipulation
	awful.key({ modkey, "Shift"   	}, "j", function () awful.client.swap.byidx(  1)	end),
	awful.key({ modkey, "Shift"   	}, "k", function () awful.client.swap.byidx( -1)	end),
	awful.key({ modkey, "Control" 	}, "j", function () awful.screen.focus_relative( 1) end),
	awful.key({ modkey, "Control" 	}, "k", function () awful.screen.focus_relative(-1) end),
	awful.key({ modkey,		   		}, "u", awful.client.urgent.jumpto),
	awful.key({ modkey,		   		}, "Tab",function ()
												awful.client.focus.history.previous()
												if client.focus then
													client.focus:raise()
												end
											end
	),
	
	-- Standard program
	awful.key({ modkey,		   		}, "Return", function () awful.util.spawn(terminal) end),
	awful.key({ modkey, "Control" 	}, "r", awesome.restart),
	awful.key({ modkey, "Shift"   	}, "q", awesome.quit),

	awful.key({ modkey,		  		}, "l",	 function () awful.tag.incmwfact( 0.05)	end),
	awful.key({ modkey,				}, "h",	 function () awful.tag.incmwfact(-0.05)	end),
	awful.key({ modkey, "Shift"   	}, "h",	 function () awful.tag.incnmaster( 1)	  end),
	awful.key({ modkey, "Shift"   	}, "l",	 function () awful.tag.incnmaster(-1)	  end),
	-- awful.key({ modkey, "Control" 	}, "h",	 function () awful.tag.incncol( 1)		 end),
	awful.key({ modkey, "Control" 	}, "l",	 function () awful.tag.incncol(-1)		 end),
	awful.key({ modkey,		   		}, "space", function () awful.layout.inc(layouts,  1) end),
	awful.key({ modkey, "Shift"   	}, "space", function () awful.layout.inc(layouts, -1) end),

	awful.key({ modkey, "Control" 	}, "n", awful.client.restore),

	-- Prompt
	awful.key({ modkey },			"r",	 function () mypromptbox[1]:run() end), --mypromptbox[mouse.screen]:run()mouse.screen

	awful.key({ modkey }, "x", 	function ()
								  awful.prompt.run({ prompt = "Run Lua code: " },
								  mypromptbox[mouse.screen].widget,
								  awful.util.eval, nil,
								  awful.util.getdir("cache") .. "/history_eval")
								end
	),
	-- Menubar
	awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
	awful.key({ modkey,		   }, "f",	  function (c) c.fullscreen = not c.fullscreen  end),
	awful.key({ modkey, "Control" }, "#9",	  function (c) c:kill()						 end),
	awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle					 ),
	awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
	--awful.key({ modkey,		   }, "o",	  awful.client.movetoscreen						),
	awful.key({ modkey,		   }, "t",	  function (c) c.ontop = not c.ontop			end),
	awful.key({ modkey,		   }, "n",
		function (c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end),
	awful.key({ modkey,		   }, "m",
		function (c)
			c.maximized_horizontal = not c.maximized_horizontal
			c.maximized_vertical   = not c.maximized_vertical
		end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = awful.util.table.join(globalkeys,
		awful.key({ modkey }, "#" .. i + 9,
				  function ()
						local screen = mouse.screen
						local tag = awful.tag.gettags(screen)[i]
						if tag then
					   		awful.tag.viewonly(tag)
						end
				  end),
		awful.key({ modkey, "Mod1" }, "#" .. i + 9,
				  function ()
				  		if i < 5 then
							local screen = mouse.screen
							local tag = awful.tag.gettags(screen)[i + 4]
							if tag then
							   awful.tag.viewonly(tag)
							end
						end
				  end),
		awful.key({ modkey, "Control" }, "#" .. i + 9,
				  function ()
					  local screen = mouse.screen
					  local tag = awful.tag.gettags(screen)[i]
					  if tag then
						 awful.tag.viewtoggle(tag)
					  end
				  end),
		awful.key({ modkey, "Shift" }, "#" .. i + 9,
				  function ()
					  local tag = awful.tag.gettags(client.focus.screen)[i]
					  if client.focus and tag then
						  awful.client.movetotag(tag)
					 end
				  end),
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
				  function ()
					  local tag = awful.tag.gettags(client.focus.screen)[i]
					  if client.focus and tag then
						  awful.client.toggletag(tag)
					  end
				  end))
end

--------------------------------------------------------
--------------switch tags with MOD+NUM_PAD--------------
--------------------------------------------------------
for i = 1, 3 do
	globalkeys = awful.util.table.join(globalkeys,
		awful.key({ modkey }, "#" .. i + 86,
				function ()
					local screen = mouse.screen
					local tag = awful.tag.gettags(screen)[i]
						if tag then
							awful.tag.viewonly(tag)
						end
					end))
end

for i = 4, 6 do
	globalkeys = awful.util.table.join(globalkeys,
		awful.key({ modkey }, "#" .. i + 79,
			function ()
				local screen = mouse.screen
				local tag = awful.tag.gettags(screen)[i]
					if tag then
						awful.tag.viewonly(tag)
					end
				end))
end

for i = 7, 9 do
	globalkeys = awful.util.table.join(globalkeys,
		awful.key({ modkey }, "#" .. i + 72,
			function ()
				local screen = mouse.screen
				local tag = awful.tag.gettags(screen)[i]
					if tag then
						awful.tag.viewonly(tag)
					end
				end))
end
--------------------------------------------------------
--------------------------------------------------------

clientbuttons = awful.util.table.join(
	awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
	awful.button({ modkey }, 1, awful.mouse.client.move),
	awful.button({ }, 2, function (c) client.focus = c; c:raise() end),
	awful.button({ modkey }, 3, awful.mouse.client.resize)),
	awful.button({ }, 3, function (c) client.focus = c; c:raise() end)

-- Set keys
root.keys(globalkeys)
-- }}}
local rootScreen 
if screen.count() > 1 then
			rootScreen = 2 
		else 
			rootScreen = 1
		end
-- {{{ Rules
awful.rules.rules = {
	-- All clients will match this rule.
	{ rule = {},
		properties = {
	  		border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			keys = clientkeys,
			buttons = clientbuttons
		}
	-- },{
	-- 	rule = { class = "MPlayer" },
	--   	properties = { floating = true }
	-- }, {
	-- 	rule = { class = "pinentry" },
	--   	properties = { floating = true }
	-- }, {
	-- 	rule = { class = "gimp" },
	--  	properties = { floating = true }
	-- }, {
	-- 	rule = { class = "X-terminal-emulator" },
	--		properties = { tag = tags[1][1] } 
	-- }, {
	-- 	rule = { class = "jetbrains-webstorm" },
	-- 	properties = { tag = tags[1][2] } 
	-- }, {
	-- 	rule = { class = "Chromium-browser" },
	-- 	properties = { tag = tags[1][2] } 
	-- }, { 
	-- 	rule = { class = "Opera" },
	-- 	properties = { tag = tags[1][3] }
	-- }, { 
	-- 	rule = { class = "Google-chrome" },
	--   	properties = { tag = tags[1][3] }
	-- }, {
	-- 	rule = { class = "Firefox" },
	-- 	properties = { tag = tags[1][3] }
	-- }, {
	-- 	rule = { class = "Nautilus" },
	-- 	properties = { tag = tags[1][4] }
	-- }, {
	-- 	rule = { class = "Thunar" },
	-- 	properties = { tag = tags[1][4] }
	-- }, {
	-- 	rule = { class = "Foobnix" },
	-- 	properties = { tag = tags[1][5] }
	-- }, {
	-- 	rule = {class = "Skype"},
	-- 	properties = {tag = tags[1][6]}
	-- }, {
	-- 	rule = {class = "VirtualBox"},
	-- 	properties = {tag = tags[1][7]}
	}
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
	-- Enable sloppy focus
--	c:connect_signal("mouse::enter", function(c)
  --	  if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
	--		and awful.client.focus.filter(c) then
	  --	  client.focus = c
		--end
	--end)

	if not startup then
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		-- awful.client.setslave(c)

		-- Put windows in a smart way, only if they does not set an initial position.
		if not c.size_hints.user_position and not c.size_hints.program_position then
			awful.placement.no_overlap(c)
			awful.placement.no_offscreen(c)
		end
	end

	local titlebars_enabled = false
	if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
		-- buttons for the titlebar
		local buttons = awful.util.table.join(
				awful.button({ }, 1, function()
					client.focus = c
					c:raise()
					awful.mouse.client.move(c)
				end),
				awful.button({ }, 3, function()
					client.focus = c
					c:raise()
					awful.mouse.client.resize(c)
				end)
				)

		-- Widgets that are aligned to the left
		local left_layout = wibox.layout.fixed.horizontal()
		left_layout:add(awful.titlebar.widget.iconwidget(c))
		left_layout:buttons(buttons)

		-- Widgets that are aligned to the right
		local right_layout = wibox.layout.fixed.horizontal()
		right_layout:add(awful.titlebar.widget.floatingbutton(c))
		right_layout:add(awful.titlebar.widget.maximizedbutton(c))
		right_layout:add(awful.titlebar.widget.stickybutton(c))
		right_layout:add(awful.titlebar.widget.ontopbutton(c))
		right_layout:add(awful.titlebar.widget.closebutton(c))

		-- The title goes in the middle
		local middle_layout = wibox.layout.flex.horizontal()
		local title = awful.titlebar.widget.titlewidget(c)
		title:set_align("center")
		middle_layout:add(title)
		middle_layout:buttons(buttons)

		-- Now bring it all together
		local layout = wibox.layout.align.horizontal()
		layout:set_left(left_layout)
		layout:set_right(right_layout)
		layout:set_middle(middle_layout)

		awful.titlebar(c):set_widget(layout)
	end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}


-- RAM usage widget
-- memwidget = awful.widget.progressbar()
-- memwidget:set_width(15)
-- memwidget:set_height(30)
-- memwidget:set_vertical(true)
-- memwidget:set_background_color('#494B4F')
-- memwidget:set_color('#AECF96')
-- -- memwidget:set_gradient_colors({ '#AECF96', '#88A175', '#FF5656' })

-- -- RAM usage tooltip
-- memwidget = widget({
--	 type = 'textbox',
--	 name = 'memwidget'
-- })

-- wicked.register(memwidget, wicked.widgets.mem,
--	 ' <span color="white">Memory:</span> $1 ($2Mb/$3Mb)')