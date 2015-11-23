--
-- Created by IntelliJ IDEA.
-- User: oleg
-- Date: 28.06.15
-- Time: 2:46
-- To change this template use File | Settings | File Templates.
--
local awful = require('awful')
local plugins = require('plugins')
local tyrannical = plugins.tyrannical
local tag = {}

tag.init = function()
    -- {{{ Tags
    -- Define a tag table which hold all screen tags.
    tyrannical.tags = {
        {
            name		= 'console',			-- Call the tag 'Term'
            init		= true,					-- Load the tag on startup
            exclusive	= true,					-- Refuse any other type of clients (by classes)
            screen		= {1, 2},				-- Create this tag on screen 1 and screen 2
            layout		= awful.layout.suit.tile, -- Use the tile layout
            instance	= {'dev', 'ops'},		-- Accept the following instances. This takes precedence over 'class'
            exec_once	= {'terminator'}, --When the tag is accessed for the first time, execute this command
            class		= { --Accept the following classes, refuse everything else (because of 'exclusive=true')
                'X-terminal-emulator', 'xterm', 'urxvt', 'aterm', 'URxvt', 'XTerm', 'konsole', 'terminator', 'gnome-terminal'
            }
        }, {
            name		= 'work',
            init		= true,
            exclusive	= true,
            no_focus_stealing_in = true,
            --icon		= "~net.png",				-- Use this icon for the tag (uncomment with a real path)
            screen		= screen.count() > 1 and 2 or 1,-- Setup on screen 2 if there is more than 1 screen, else on screen 1
            layout		= awful.layout.suit.max,	-- Use the max layout
            class 		= {
                "jetbrains-webstorm", "jetbrains-android-studio", "jetbrains-android-studi", "Chromium-browser"
            }
        }, {
            name 		= 'www',
            init		= true,
            exclusive	= true,
            no_focus_stealing_in = true,
            screen		= 1,
            layout		= awful.layout.suit.max,
            class		= {
                'Opera', 'Firefox', 'Google-chrome', 'Chrome', 'Opera developer', 'Vivaldi', 'Opera beta'
            }
        }, {
            name 		= 'im',
            init		= true,
            exclusive	= true,
            no_focus_stealing_in = true,
            screen 		= 1,
            clone_on	= 2, -- Create a single instance of this tag on screen 1, but also show it on screen 2
            -- The tag can be used on both screen, but only one at once
            layout 		= awful.layout.suit.tile,
            class 		= {
                'Skype', 'Telegram', 'Scudcloud', 'Slack'
            }
        }, {
            name		= 'files',
            init		= true, -- This tag wont be created at startup, but will be when one of the
            -- client in the 'class' section will start. It will be created on
            -- the client startup screen
            exclusive	= true,
            no_focus_stealing_in = true,
            layout 		= awful.layout.suit.tile,
            class 		= {
                'Thunar', 'Nautilus', 'Deluge'
            }
        }, {
            name		= 'media',
            init		= true, -- This tag wont be created at startup, but will be when one of the
            -- client in the 'class' section will start. It will be created on
            -- the client startup screen
            exclusive	= true,
            layout 		= awful.layout.suit.tile,
            class 		= {
                'Foobnix', 'Steam'
            }
        }, {
            name		= 'vm',
            init		= true, -- This tag wont be created at startup, but will be when one of the
            -- client in the 'class' section will start. It will be created on
            -- the client startup screen
            exclusive	= true,
            no_focus_stealing_in = true,
            layout		= awful.layout.suit.max,
            class		= {
                "VirtualBox", "Genymotion", "Player"
            }
        }, {
            name		= 'edit',
            init		= true, -- This tag wont be created at startup, but will be when one of the
            -- client in the 'class' section will start. It will be created on
            -- the client startup screen
            exclusive	= true,
            layout 		= awful.layout.suit.max,
            class		= {
                'Sublime_text'
            },
            no_focus_stealing_in = true,
            layout 		= awful.layout.suit.tile
        }
    }

    -- Ignore the tag 'exclusive' property for the following clients (matched by classes)
    tyrannical.properties.intrusive = {
        'ksnapshot', 'pinentry', 'gtksu', 'kcalc', 'xcalc',
        'feh', 'Gradient editor', 'About KDE', 'Paste Special', 'Background color',
        'kcolorchooser', 'plasmoidviewer', 'Xephyr', 'kruler', 'plasmaengineexplorer',
    }

    -- Ignore the tiled layout for the matching clients
    tyrannical.properties.floating = {
        'MPlayer', 'pinentry', 'ksnapshot', 'pinentry', 'gtksu',
        'xine', 'feh', 'kmix', 'kcalc', 'xcalc',
        'yakuake', 'Select Color$', 'kruler', 'kcolorchooser', 'Paste Special',
        'New Form', 'Insert Picture', 'kcharselect', 'mythfrontend', 'plasmoidviewer'
    }

    -- Make the matching clients (by classes) on top of the default layout
    tyrannical.properties.ontop = {
        'Xephyr', 'ksnapshot', 'kruler'
    }

    -- Force the matching clients (by classes) to be centered on the screen on init
    tyrannical.properties.centered = {
        'kcalc'
    }

    tyrannical.settings.block_children_focus_stealing = true --Block popups ()
    tyrannical.settings.group_children = true --Force popups/dialogs to have the same tags as the parent client

    -- }}}

    return awful.tag.gettags()
end

return tag
