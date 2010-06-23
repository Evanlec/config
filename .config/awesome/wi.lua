-------------------
-- tdy's widgets --
-- awesome 3.4.3 --
-- <tdy@gmx.com> --
-------------------

--[[ TODO:
* phase out wicked
* phase out C graphs/progressbars
* clean up all the ugly/inefficient code
--]]

require("vicious")
require("wicked")

-- {{{ SPACERS
spacer = widget({ type = "textbox" })
spacer.text = " "
tab = widget({ type = "textbox" })
tab.text = "       "
-- }}}

-- {{{ PROCESSOR
-- cpu0 info
cpuinfo = widget({ type = "textbox" })
vicious.register(cpuinfo, vicious.widgets.cpuinf, "<span color='#d6d6d6'>cpu</span>${cpu0 ghz}GHz")

-- cpu0 graph
cpugraph = awful.widget.graph()
cpugraph:set_width(40)
cpugraph:set_height(12)
cpugraph:set_background_color(beautiful.bg_widget)
cpugraph:set_border_color(beautiful.bg_widget)
cpugraph:set_gradient_colors({ beautiful.fg_widget, beautiful.bg_widget })
cpugraph:set_gradient_angle(180)
vicious.register(cpugraph, vicious.widgets.cpu, "$2")

-- cpu0 %
cpupct = widget({ type = "textbox" })
vicious.register(cpupct, vicious.widgets.cpu, "$2%", 2)

-- cpu1 graph
cpugraph1 = awful.widget.graph()
cpugraph1:set_width(40)
cpugraph1:set_height(12)
cpugraph1:set_background_color(beautiful.bg_widget)
cpugraph1:set_border_color(beautiful.bg_widget)
cpugraph1:set_gradient_colors({ beautiful.fg_widget, beautiful.bg_widget })
cpugraph1:set_gradient_angle(180)
wicked.register(cpugraph1, wicked.widgets.cpu, "$3")

-- cpu1 %
cpupct1 = widget({ type = "textbox" })
wicked.register(cpupct1, wicked.widgets.cpu, "$3%", 2)
-- }}}

-- {{{ MEMORY
-- used
memused = widget({ type = "textbox" })
vicious.register(memused, wicked.widgets.mem, "<span color='#d6d6d6'>ram</span>$2MB", 5)

-- bar
membar = awful.widget.progressbar()
membar:set_width(40)
membar:set_height(12)
membar:set_border_color(beautiful.bg_widget)
membar:set_background_color(beautiful.bg_widget)
membar:set_gradient_colors({ beautiful.fg_widget, beautiful.bg_widget })
vicious.register(membar, vicious.widgets.mem, "$1", 5)

-- %
mempct = widget({ type = "textbox" })
vicious.register(mempct, wicked.widgets.mem, "$1%", 5)
-- }}}

-- {{{ SWAP
-- used
swapused = widget({ type = "textbox" })
vicious.register(swapused, vicious.widgets.mem, "<span color='#d6d6d6'>swap</span>$6MB", 10)

-- bar
swapbar = awful.widget.progressbar()
swapbar:set_width(40)
swapbar:set_height(12)
swapbar:set_border_color(beautiful.bg_widget)
swapbar:set_background_color(beautiful.bg_widget)
swapbar:set_gradient_colors({ beautiful.fg_widget, beautiful.bg_widget })
vicious.register(swapbar, vicious.widgets.mem, "$5", 10)

-- %
swappct = widget({ type = "textbox" })
vicious.register(swappct, vicious.widgets.mem, "$5%", 10)
-- }}}

-- {{{ ROOT FILESYSTEM
-- used
myrootfsusedwidget = widget({ type = "textbox" })
wicked.register(myrootfsusedwidget, wicked.widgets.fs, "<span color='#d6d6d6'>root</span>${/ used}", 90)

-- bar
rootfsbar = awful.widget.progressbar()
rootfsbar:set_width(40)
rootfsbar:set_height(12)
rootfsbar:set_border_color(beautiful.bg_widget)
rootfsbar:set_background_color(beautiful.bg_widget)
rootfsbar:set_gradient_colors({ beautiful.fg_widget, beautiful.bg_widget })
vicious.register(rootfsbar, vicious.widgets.fs, "${/ used_p}", 90)

-- %
rootfspct = widget({ type = "textbox" })
vicious.register(rootfspct, vicious.widgets.fs, "${/ used_p}%", 90)
-- }}}

-- {{{ HOME FILESYSTEM
-- used
myhomefsusedwidget = widget({ type = "textbox" })
wicked.register(myhomefsusedwidget, wicked.widgets.fs, "<span color='#d6d6d6'>home</span>${/home used}", 90)

-- bar
homefsbar = awful.widget.progressbar()
homefsbar:set_width(40)
homefsbar:set_height(12)
homefsbar:set_border_color(beautiful.bg_widget)
homefsbar:set_background_color(beautiful.bg_widget)
homefsbar:set_gradient_colors({ beautiful.fg_widget, beautiful.bg_widget })
vicious.register(homefsbar, vicious.widgets.fs, "${/home used_p}", 90)

-- %
homefspct = widget({ type = "textbox" })
vicious.register(homefspct, vicious.widgets.fs, "${/home used_p}%", 90)
-- }}}

--[[ {{{ DATA FILESYSTEM
-- used
mydatafsusedwidget = widget({ type = "textbox" })
wicked.register(mydatafsusedwidget, wicked.widgets.fs, "<span color='#d6d6d6'>data</span>${/windows/Data used}", 90)

-- bar
datafsbar = awful.widget.progressbar()
datafsbar:set_width(40)
datafsbar:set_height(12)
datafsbar:set_border_color(beautiful.bg_widget)
datafsbar:set_background_color(beautiful.bg_widget)
datafsbar:set_gradient_colors({ beautiful.fg_widget, beautiful.bg_widget })
vicious.register(datafsbar, vicious.widgets.fs, "${/windows/Data used_p}", 90)

-- %
datafspct = widget({ type = "textbox" })
vicious.register(datafspct, vicious.widgets.fs, "${/windows/Data used_p}%", 90)
-- }}}
--]]

-- {{{ NETWORK
-- tx
txwidget = widget({ type = "textbox" })
vicious.register(txwidget, vicious.widgets.net, "<span color='#d6d6d6'>up</span>${eth0 tx_mb}MB", 15)

-- up graph
upgraph = awful.widget.graph()
upgraph:set_width(40)
upgraph:set_height(12)
upgraph:set_background_color(beautiful.bg_widget)
upgraph:set_border_color(beautiful.bg_widget)
upgraph:set_gradient_colors({ beautiful.fg_widget, beautiful.bg_widget })
upgraph:set_gradient_angle(180)
vicious.register(upgraph, vicious.widgets.net, "${eth0 up_kb}")

-- up speed
upwidget = widget({ type = "textbox" })
wicked.register(upwidget, wicked.widgets.net, "${eth0 up_kb}k/s", 2)

-- rx
rxwidget = widget({ type = "textbox" })
vicious.register(rxwidget, vicious.widgets.net, "<span color='#d6d6d6'>down</span>${eth0 rx_mb}MB", 15)

-- down graph
downgraph = awful.widget.graph()
downgraph:set_width(40)
downgraph:set_height(12)
downgraph:set_background_color(beautiful.bg_widget)
downgraph:set_border_color(beautiful.bg_widget)
downgraph:set_gradient_colors({ beautiful.fg_widget, beautiful.bg_widget })
downgraph:set_gradient_angle(180)
vicious.register(downgraph, vicious.widgets.net, "${eth0 down_kb}")

-- down speed
downwidget = widget({ type = "textbox" })
wicked.register(downwidget, wicked.widgets.net, "${eth0 down_kb}k/s", 2)
-- }}}

-- {{{ WEATHER
weatherwidget = widget({ type = "textbox" })
vicious.register(weatherwidget, vicious.widgets.weather, "<span color='#d6d6d6'>${sky}</span> @ ${tempf}°F on", 1200, "KOUN")

function get_forecast(mode)
    local s, cutoff
    if mode == "quick" then
        s = " | sed 's/Tomorrow Night/.../'"
        cutoff = "/Tomorrow Night/"
    elseif mode == "full" then
        s = ""
        cutoff = 38
    end

    local fp = io.popen("sed -n '1," .. cutoff .. "p' /tmp/weather" .. s)
    local forecast = fp:read("*a")
    fp:close()

    return forecast
end

-- buttons
weatherwidget:buttons(awful.util.table.join(
    awful.button({ }, 1, function ()
        naughty.notify { text = get_forecast("quick"), timeout = 5, hover_timeout = 0.5 }
    end),
    awful.button({ }, 2, function ()
        awful.util.spawn(browser .. " http://www.accuweather.com/us/ok/norman/73071/city-weather-forecast.asp?partner=accuweather&u=1&traveler=0", false)
        awful.tag.viewonly(tags[1][2])
    end),
    awful.button({ }, 3, function ()
        naughty.notify { text = get_forecast("full"), timeout = 10, hover_timeout = 0.5 }
    end)))
-- }}}

-- {{{ VOLUME
vollabel = widget({ type = "imagebox" })

myvolbarwidget = widget({ type = "progressbar" })
myvolbarwidget.width          = 10
myvolbarwidget.height         = 0.98
myvolbarwidget.gap            = 0
myvolbarwidget.border_padding = 2
myvolbarwidget.border_width   = 0
myvolbarwidget.ticks_count    = 5
myvolbarwidget.ticks_gap      = 1
myvolbarwidget.vertical       = true
myvolbarwidget:bar_properties_set("vol", {
    bg        = beautiful.bg_widget,
    fg        = beautiful.fg_widget,
    fg_center = beautiful.fg_center_widget,
    fg_end    = beautiful.fg_end_widget,
    fg_off    = beautiful.fg_off_widget,
    min_value = 0,
    max_value = 100
})

function get_vol()
    local fp = io.popen("amixer get Master")
    local amixer = fp:read("*a")
    fp:close()

    local level = amixer:match("([%d]?[%d]?[%d]?)%%]")
    if string.find(amixer, "%[off%]") or level == "0" then
        vollabel.image = image(beautiful.widget_mute)
        level = 0
    else
        vollabel.image = image(beautiful.widget_vol)
    end

    return tonumber(level)
end

wicked.register(myvolbarwidget, get_vol, "$1", 2, "vol")

function popup_vol_up()
    awful.util.spawn("amixer set Master 10+%", false)
end

function popup_vol_dn()
    awful.util.spawn("amixer set Master 10-%", false)
end

-- buttons
myvolbarwidget:buttons(awful.util.table.join(
    awful.button({ }, 1, popup_vol_up),
    awful.button({ }, 3, popup_vol_dn)))
vollabel:buttons(awful.util.table.join(
    awful.button({ }, 1, popup_vol_up),
    awful.button({ }, 3, popup_vol_dn)))
-- }}}

-- {{{ PACMAN
paclabel = widget({ type = "imagebox" })

function get_pac()
    local updates = -1
    local fp = io.popen("yes|pacman -Sup")
    if not fp then
        paclabel.image = image(beautiful.widget_upg)
        return updates
    else
        updates = updates + 1
    end

    for line in fp:lines() do
        updates = updates + 1
    end
    fp:close()

    updates = updates - 2
    if updates ~= 0 then
        paclabel.image = image(beautiful.widget_upg)
    else
        paclabel.image = image(beautiful.widget_pac)
    end
    return updates
end

-- package updates
pacwidget = widget({ type = "textbox" })
vicious.register(pacwidget, get_pac, "$1", 300)

function get_upg()
    local fp = io.popen("yes|pacman -Sup")
    if not fp then
        return "?"
    end
    local updates = ""
    for line in fp:lines() do
        pkg = line:match("[%w]+tp://.*/(.+).pkg.tar.gz")
        if pkg then
            updates = updates .. "\n" .. pkg
        end
    end
    fp:close()

    if updates == "" then
        return "System is up to date"
    else
        return "Available updates:\n" .. updates .. "\n"
    end
end

function popup_pac()
    naughty.notify { text = get_upg(), timeout = 5, hover_timeout = 0.5, position = "bottom_right" }
end

-- buttons
paclabel:buttons(awful.util.table.join(awful.button({ }, 1, popup_pac)))
pacwidget:buttons(awful.util.table.join(awful.button({ }, 1, popup_pac)))
-- }}}

-- {{{ MAIL
maillabel = widget({ type = "imagebox" })
maillabel.image = image(beautiful.widget_mail)

function get_mail()
    local args = {}
    local fd = io.open("/tmp/mail")
    if not fd then
        args["{aur_notify}"] = -1
        args["{all}"] = "?"
        maillabel.image = image(beautiful.widget_mailn)
        return args
    end

    for line in fd:lines() do
        line = wicked.helper.splitbywhitespace(line)
        name = line[1]
        args["{" .. name .. "}"] = tonumber(line[3])
    end
    fd:close()

    fd = io.open("/tmp/mail")
    args["{all}"] = fd:read("*a")
    fd:close()

    if args["{aur_notify}"] ~= 0 then
        maillabel.image = image(beautiful.widget_mailn)
    else
        maillabel.image = image(beautiful.widget_mail)
    end
    return args
end

-- aur-notify count
mailwidget = widget({ type = "textbox" })
vicious.register(mailwidget, get_mail, "${aur_notify}", 360)

function popup_mail_left()
    naughty.notify { text = get_mail()["{all}"], timeout = 5, hover_timeout = 0.5, position = "bottom_right" }
end

function popup_mail_middle()
    awful.util.spawn(browser .. " http://mail.google.com/", false)
    awful.tag.viewonly(tags[1][2])
end

-- buttons
maillabel:buttons(awful.util.table.join(
    awful.button({ }, 1, popup_mail_left),
    awful.button({ }, 2, popup_mail_middle)))
mailwidget:buttons(awful.util.table.join(
    awful.button({ }, 1, popup_mail_left),
    awful.button({ }, 2, popup_mail_middle)))
-- }}}

-- {{{ THERMAL
thermallabel= widget({ type = "imagebox" })
thermallabel.image = image(beautiful.widget_temp)

-- cpu temp
thermalwidget = widget({ type = "textbox" })
vicious.register(thermalwidget, vicious.widgets.thermal, "$1°C", 30, "thermal_zone0")
-- }}}

-- {{{ MPD
mpdlabel = widget({ type = "imagebox" })
mpdlabel.image = image(beautiful.widget_mpd)
mpdspacer = widget({ type = "textbox" })
mpdspacer.text = "<span color='#222222'> </span>"
mpdspacer.bg = "#908884"

-- current song
mpdwidget = widget({ type = "textbox" })
mpdwidget.bg = "#908884"
vicious.register(mpdwidget, vicious.widgets.mpd, "<span color='#222222'> $1 </span>", nil, { 30, "mpd" })

-- buttons
mpdwidget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("mpc next", false) end),
    awful.button({ }, 2, function () awful.util.spawn("mpc toggle", false) end),
    awful.button({ }, 3, function () awful.util.spawn("mpc prev", false) end)))
mpdlabel:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("mpc next", false) end),
    awful.button({ }, 2, function () awful.util.spawn("mpc toggle", false) end),
    awful.button({ }, 3, function () awful.util.spawn("mpc prev", false) end)))
-- }}}

-- vim:ts=4 sw=4 sts=4 et
