----------------------------
-- tdy's thinkpad widgets --
--     awesome 3.4.3      --
--     <tdy@gmx.com>      --
----------------------------

-- {{{ BATTERY
batlabel = widget({ type = "imagebox" })

batbar = widget({ type = "progressbar" })
batbar.width          = 10
batbar.height         = 0.98
batbar.gap            = 0
batbar.border_padding = 2
batbar.border_width   = 0
batbar.ticks_count    = 5
batbar.ticks_gap      = 1
batbar.vertical       = true
batbar:bar_properties_set("bat0", {
    bg        = beautiful.bg_widget,
    fg_center = beautiful.fg_center_widget,
    fg_end    = beautiful.fg_end_widget,
    fg_off    = beautiful.fg_off_widget,
    min_value = 0,
    max_value = 100
})

function get_bat()
    local thresh = 15
    local args = {}

    local fd = io.open("/proc/acpi/battery/BAT0/info")
    if not fd then
        args["{level}"] = 0
        args["{time}"] = 0
        args["{state}"] = "N/A"
        batlabel.image = image(beautiful.widget_ac)
        return args
    end
    local info = fd:read("*a")
    if info:match("present:%s+no") then
        args["{level}"] = 0
        args["{time}"] = 0
        args["{state}"] = "N/A"
        batlabel.image = image(beautiful.widget_ac)
        return args
    end
    local capacity = tonumber(info:match("last full capacity:%s+(%d+)"))
    fd:close()

    local fd = io.open("/proc/acpi/battery/BAT0/state")
    local state = fd:read("*a")
    local status = state:match("charging state:%s+(%w+)")
    local remaining = tonumber(state:match("remaining capacity:%s+(%d+)"))
    local rate = tonumber(state:match("present rate:%s+(%d+)"))
    fd:close()

    local level = math.floor((((remaining * 100) / capacity) * 100) / 100)
    local time = "N/A"
    local hours, mod = math.modf(remaining / rate)
    if status == "discharging" then
        time = math.floor(mod * 60) .. "m"
    elseif status == "charging" then
        hours, mod = math.modf((capacity - remaining)/ rate)
        time = math.floor(mod * 60) .. "m"
    end
    if hours ~= 0 then
        time = hours .. "h " .. time
    end

    if status == "discharging" then
        batlabel.image = image(beautiful.widget_bat)
        batbar:bar_properties_set("bat0", { fg = beautiful.fg_widget })
        if level <= thresh then
            blink = not blink
            if blink then
                batlabel.image = image(beautiful.widget_crit)
                batbar:bar_properties_set("bat0", { fg = "#cd7171" })
            end
        end
    else
        batlabel.image = image(beautiful.widget_ac)
        batbar:bar_properties_set("bat0", { fg = beautiful.fg_widget })
        if status == "charging" then
            charging = not charging
            if charging then
                batlabel.image = image(beautiful.widget_blank)
            end
        end
    end

    args["{level}"] = level
    args["{state}"] = status
    args["{time}"] = time

    return args
end

blink = true
charging = true
wicked.register(batbar, get_bat, "${level}", nil, "bat0")

function popup_bat()
    naughty.notify { text = "Charge : " .. get_bat()["{level}"] .. "%" .. "\nState  : " .. get_bat()["{state}"] .. " (" .. get_bat()["{time}"] .. ")", timeout = 5, hover_timeout = 0.5 }
end

-- buttons
batbar:buttons(awful.util.table.join(awful.button({ }, 1, popup_bat)))
batlabel:buttons(awful.util.table.join(awful.button({ }, 1, popup_bat)))
-- }}}

-- {{{ WIFI
wifilabel = widget({ type = "imagebox" })

function get_wifi()
    local fd = io.open("/proc/net/wireless")
    local wifi = fd:read("*a"):match("eth1:%s*%d+%s*(%d+)")
    fd:close()

    if wifi == "0" then
        wifilabel.image = image(beautiful.widget_nowifi)
    else
        wifilabel.image = image(beautiful.widget_wifi)
    end

    return wifi
end

mywifibarwidget = widget({ type = "progressbar" })
mywifibarwidget.width          = 10
mywifibarwidget.height         = 0.98
mywifibarwidget.gap            = 0
mywifibarwidget.border_padding = 2
mywifibarwidget.border_width   = 0
mywifibarwidget.ticks_count    = 5
mywifibarwidget.ticks_gap      = 1
mywifibarwidget.vertical       = true
mywifibarwidget:bar_properties_set("wifi", {
    bg        = beautiful.bg_widget,
    fg        = beautiful.fg_widget,
    fg_center = beautiful.fg_center_widget,
    fg_end    = beautiful.fg_end_widget,
    fg_off    = beautiful.fg_off_widget,
    min_value = 0,
    max_value = 100
})

wicked.register(mywifibarwidget, get_wifi, "$1", 60, "wifi")
-- }}}
