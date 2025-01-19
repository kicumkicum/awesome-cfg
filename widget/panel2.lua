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
local calendar = require("awful.widget.calendar_popup")

local panel = {}
local sound_timer = nil

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

            -- Логика для отображения иконок в зависимости от заряда
            if status == "Charging" then
                widget:set_text(string.format("🔌 %s%%", charge))
                if sound_timer then
                    sound_timer:stop()
                    sound_timer = nil
                end
            elseif tonumber(charge) <= 10 then
                widget:set_text(string.format("🔋 Low: %s%%", charge))
                if not sound_timer then
                    sound_timer = gears.timer {
                        timeout = 5,  -- Период для цикличного воспроизведения (каждые 10 секунд)
                        autostart = true,
                        callback = play_sound
                    }
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

    widget:connect_signal("mouse::enter", function()
         local f = io.popen("acpi")
         local battery_info = f:read("*all")
         f:close()

         -- Используем регулярное выражение для извлечения данных
         local status, charge, time = battery_info:match("Battery %d+: ([%a%s]+), (%d+)%%,?%s*([%d+:%d+:%d+]*)")
         local b_text = "Status: " .. status .. "\n" ..
              "Charge: " .. charge
          if not time then
            b_text = b_text .. "\n" .. "Time remaining: " .. time
          end

         naughty.notify({
            title = "Battery Info",
            text = b_text,
            timeout = 5  -- Всплывающее окно исчезает через 5 секунд
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
      -- Календарь
      local mycalendar = awful.widget.calendar_popup.month({
          font = "monospace 10",     -- Шрифт
          fg_normal = "#ffffff",     -- Цвет текста
          fg_focus = "#ff0000",      -- Цвет выделенного дня
          bg_normal = "#333333",     -- Цвет фона
          bg_focus = "#444444",      -- Цвет фона выделенного дня
          radius = 10,               -- Радиус углов
          spacing = 5,               -- Расстояние между днями
          attach_to = {},            -- Отключаем автоматическое привязывание
          prev_month_button = wibox.widget {
              text = "<",           -- Кнопка для предыдущего месяца
              widget = wibox.widget.textbox,
          },
          next_month_button = wibox.widget {
              text = ">",           -- Кнопка для следующего месяца
              widget = wibox.widget.textbox,
          },
      })

   -- Функция для переключения видимости календаря
   local calendar_visible = false
   local function toggle_calendar()
       if calendar_visible then
           mycalendar:toggle() -- Скрыть календарь
       else
           mycalendar:toggle() -- Показать календарь
       end
       calendar_visible = not calendar_visible
   end

   -- Привязываем календарь к клику по часам
   anchor:connect_signal("button::press", function(_, _, _, button)
       if button == 1 then  -- Левый клик
--            toggle_calendar()
       end
   end)

   mycalendar:attach(anchor, "tr", { on_hover = false })

end


panel.createClock = function()
    local clock = awful.widget.textclock()
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

