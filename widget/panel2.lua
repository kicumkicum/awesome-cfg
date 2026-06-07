--
-- Created by IntelliJ IDEA.
-- User: oleg
-- Date: 03.07.15
-- Time: 1:43
-- To change this template use File | Settings | File Templates.
--
local awful = require('awful')
local wibox = require('wibox')
local naughty = require('naughty')
local gears = require('gears')
local abutton = require('awful.button')
local calendar = require("awful.widget.calendar_popup")

local panel = {}
local sound_timer = nil

-- Suspend on critical battery (widget polls acpi). Cooldown avoids instant re-suspend after resume.
local low_battery_suspend_last = 0
local LOW_BATTERY_SUSPEND_COOLDOWN_SEC = 90

local function play_sound()
    os.execute("paplay /usr/share/sounds/sound-icons/guitar-13.wav &")  -- Укажите путь к вашему звуковому файлу
end

local function createBattery()
    local widget = wibox.widget.textbox()

    -- Обновление виджета каждую минуту
    awful.widget.watch("acpi", 3, function(_, stdout)
--         local battery_status = stdout:match("(%a+), (%d+)%%")  -- извлекаем статус и заряд батареи
--         local status, charge, remaining_time = stdout:match("Battery %d+: (%a+), (%d+)%%, (%d+:%d+:%d+) remaining")

        local pattern = "Battery %d+: ([%a%s]+), (%d+)%%,?%s*([%d+:%d+:%d+]*)"
        --
        -- -- Применение регулярного выражения к строкам
        local status, charge, remaining_time = stdout:match(pattern)

        -- Отображаем статус батареи и процент заряда
        widget:set_text(string.format("Battery: %s%%", charge))

        -- Можно добавить логику для отображения иконок в зависимости от уровня заряда:
        if status and charge then
            -- Отображаем информацию о батарее
            widget:set_text(string.format("Battery: %s%% (%s)", charge, status))

            if status == "Charging" or tonumber(charge) > 5 then
                low_battery_suspend_last = 0
            end

            -- Логика для отображения иконок в зависимости от заряда
            if status == "Charging" then
                widget:set_text(string.format("🔌 %s%%", charge))
                if sound_timer then
                    sound_timer:stop()
                    sound_timer = nil
                end
            elseif tonumber(charge) <= 5 then
                widget:set_text(string.format("🔋 Low: %s%%", charge))
                if not sound_timer then
                    sound_timer = gears.timer {
                        timeout = 5,  -- Период для цикличного воспроизведения (каждые 10 секунд)
                        autostart = true,
                        callback = play_sound
                    }
                end
                local now = os.time()
                if now - low_battery_suspend_last >= LOW_BATTERY_SUSPEND_COOLDOWN_SEC then
                    low_battery_suspend_last = now
                    if sound_timer then
                        sound_timer:stop()
                        sound_timer = nil
                    end
                    awful.spawn({ "systemctl", "suspend" })
                end
            elseif tonumber(charge) < 50 then
                widget:set_text(string.format("🔋 %s%%", charge))
                if sound_timer then
                    sound_timer:stop()
                    sound_timer = nil
                end
            else
                widget:set_text(string.format("🔋 %s%%", charge))
                if sound_timer then
                    sound_timer:stop()
                    sound_timer = nil
                end
            end
        else
            widget:set_text("Battery: Unknown")
            if sound_timer then
                sound_timer:stop()
                sound_timer = nil
            end
        end
    end)

    widget:connect_signal("button::press", function(_, _, _, button)
        if button ~= 1 then return end

        local f = io.popen("acpi")
        local battery_info = f:read("*all")
        f:close()

        local status, charge, time = battery_info:match("Battery %d+: ([%a%s]+), (%d+)%%,?%s*([%d+:%d+:%d+]*)")
        local b_text = "Status: " .. (status or "?") .. "\n" ..
            "Charge: " .. (charge or "?") .. "%"
        if time and time ~= "" then
            b_text = b_text .. "\nTime remaining: " .. time
        end

        naughty.notify({
            title = "Battery Info",
            text = b_text,
            timeout = 5,
        })
    end)

    return widget
end


panel.init = function()
    return {
        textClock = panel.createClock(),
        tagList = panel.createTagList(),
        taskList = panel.createTaskList(),
        battery = createBattery(),
    }
end


local function createCalendar(anchor)
    local mycalendar = awful.widget.calendar_popup.month({
        font = "monospace 10",
        spacing = 5,
        style_header = {
            fg_color = "#ffffff",
            markup = function(t) return "<b>" .. t .. "</b>" end,
        },
        style_weekday = { fg_color = "#ffffff", bg_color = "#333333" },
        style_normal = { fg_color = "#ffffff", bg_color = "#333333" },
        style_focus = { fg_color = "#ff0000", bg_color = "#444444" },
    })

    local cal_widget = mycalendar:get_widget()
    local original_fn_embed = cal_widget._private.fn_embed

    local function nav_button(symbol, delta)
        local btn = wibox.widget.textbox(symbol)
        btn:buttons(gears.table.join(
            abutton({}, 1, function()
                mycalendar:call_calendar(delta)
            end)
        ))
        return btn
    end

    cal_widget:set_fn_embed(function(widget, flag, date)
        local embedded = original_fn_embed(widget, flag, date)
        if flag == "header" then
            return wibox.widget {
                nav_button("◀", -1),
                {
                    embedded,
                    margins = 4,
                    widget = wibox.container.margin,
                },
                nav_button("▶", 1),
                spacing = 8,
                layout = wibox.layout.fixed.horizontal,
            }
        end
        return embedded
    end)

    mycalendar:attach(anchor, "tr", { on_hover = false })
end


panel.createClock = function()
    local clock = awful.widget.textclock("%H:%M")
--     local month_calendar = awful.widget.calendar_popup.month()
--     month_calendar:attach( clock, "tr" )
--     month_calendar:toggle()
    createCalendar(clock)
    return clock
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

