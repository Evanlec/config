-------------------
-- tdy's config  --
-- awesome 3.4.3 --
-- <tdy@gmx.com> --
-------------------

-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/themes/dust/theme.lua")

-- Import my custom widgets
require("wi")
-- Import drop-down terminal code
require("teardrop")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
icon_theme = "/home/el/.icons/black-white/128x128"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
    names = { "01", "02", "03", "04", "05", "06", "07", "08", "09", "10" },
    layouts = { layouts[1], layouts[9], layouts[1], layouts[1], layouts[1],
                layouts[1], layouts[2], layouts[12], layouts[9], layouts[12] }
}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
     tags[s] = awful.tag(tags.names, s, tags.layouts)
     awful.tag.setproperty(tags[s][1], "mwfact", 0.75)
     awful.tag.setproperty(tags[s][3], "mwfact", 0.405)
     awful.tag.setproperty(tags[s][4], "mwfact", 0.405)
     awful.tag.setproperty(tags[s][5], "mwfact", 0.405)
     awful.tag.setproperty(tags[s][7], "mwfact", 0.105)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
    { "manual", terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/aw.lua" }
}
--
--mydevelopmentmenu = {
--    { "geany", "geany", "/usr/share/icons/hicolor/16x16/apps/geany.png" },
--    { "spyder", "spyder", awful.util.getdir("config") .. "/icons/spyder.png" }
--}
--
--mymultimediamenu = {
--    { "2mandvd", "2mandvd", "/usr/share/pixmaps/2mandvd.png" },
--    { "dvdstyler", "dvdstyler", "/usr/share/pixmaps/dvdstyler.png" },
--    { "mandvd", "mandvd", "/usr/share/pixmaps/mandvd.png" },
--    { "vlc", "vlc", icon_theme .. "/apps/256/vlc.png" },
--    { "xfburn", "xfburn", "/usr/share/icons/gnome/16x16/devices/media-cdrom.png" },
--}
--
mymainmenu = awful.menu({
    items = {
        { "awesome", myawesomemenu, awful.util.getdir("config") .. "/icons/awesomemenu-dust.png" },
--        { "development", mydevelopmentmenu, icon_theme .. "/categories/applications-development.png" },
--        { "multimedia", mymultimediamenu, icon_theme .. "/categories/applications-multimedia.png" },
--        { "-----------", "" },
--        { "firefox", "firefox", icon_theme .. "/apps/256/firefox.png" },
--        { "thunderbird", "thunderbird", icon_theme .. "/apps/256/thunderbird.png" },
--        { "virtualbox", "VirtualBox", icon_theme .. "/apps/virtualbox.png" },
--        { "thunar", "thunar", icon_theme .. "/apps/system-file-manager.png" },
--        { "-----------", "" },
--        { "reload", awesome.restart, awful.util.getdir("config") .. "/icons/reload.png" },
--        { "logout", awesome.quit, awful.util.getdir("config") .. "/icons/logout.png" }
    }
})

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon14),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({}, "<span color='#d6d6d6'>%a, %m/%d</span> @ %l:%M %p ")

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mygraphbox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", height = 16, screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mytaglist[s], spacer,
            mypromptbox[s],
            mylayoutbox[s], spacer,
            layout = awful.widget.layout.horizontal.leftright
        },
        mytextclock, spacer,
        weatherwidget, spacer,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }

    -- Create the graphbox
    mygraphbox[s] = awful.wibox({ position = "bottom", height = 14, screen = s })
    mygraphbox[s].widgets = {
        mylauncher, spacer, spacer, spacer,
        cpuinfo, cpugraph, cpupct, spacer, cpugraph1, cpupct1, tab,
        memused, membar, mempct, tab,
        swapused, swapbar, swappct, tab,
        myrootfsusedwidget, rootfsbar, rootfspct, tab,
        myhomefsusedwidget, homefsbar, homefspct, tab,
        mydatafsusedwidget, datafsbar, datafspct, tab,
        txwidget, upgraph, upwidget, tab,
        rxwidget, downgraph, downwidget,
        layout = awful.widget.layout.horizontal.leftright,
        {
            spacer, s == 1 and mysystray or nil,
            myvolbarwidget, vollabel,
            thermalwidget, thermallabel,
            mailwidget, maillabel,
            pacwidget, paclabel,
            mpdwidget, mpdlabel,
            layout = awful.widget.layout.horizontal.rightleft
        }
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey, "Shift"   }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show(true)        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "p",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,            }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey,           }, "j",     function () awful.client.incwfact( 0.05)    end),
    awful.key({ modkey,           }, "k",     function () awful.client.incwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            "F2",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

    -- Drop-down terminal
    awful.key({ modkey }, "`", function ()
        teardrop("xterm", "bottom", "right", 700, .40, true)
    end),

    -- {{{ Tag 0
    awful.key({ modkey }, 0,
              function ()
                  local screen = mouse.screen
                  if tags[screen][10] then
                      awful.tag.viewonly(tags[screen][10])
                  end
              end),
    awful.key({ modkey, "Control" }, 0,
              function ()
                  local screen = mouse.screen
                  if tags[screen][10] then
                      tags[screen][10].selected = not tags[screen][10].selected
                  end
              end),
    awful.key({ modkey, "Shift" }, 0,
              function ()
                  if client.focus and tags[client.focus.screen][10] then
                      awful.client.movetotag(tags[client.focus.screen][10])
                  end
              end),
    awful.key({ modkey, "Control", "Shift" }, 0,
              function ()
                  if client.focus and tags[client.focus.screen][10] then
                      awful.client.toggletag(tags[client.focus.screen][10])
                  end
              end)
    -- }}}
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "F4",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    -- { rule = { class = "MPlayer" },
    --  properties = { floating = true } },
    { rule = { class = "pidgin" },
      properties = { tag = tags[1][7] } },
    { rule = { class = "Shredder" },
      properties = { tag = tags[1][9] } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    -- Deal with window gaps
    c.size_hints_honor = false
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Timers
-- /tmp/mail
aurhook = timer { timeout = 880 }
aurhook:add_signal("timeout", function()
    os.execute("ruby /home/tim/bin/mail.rb > /tmp/mail")
end)
aurhook:start()
-- }}}

-- /tmp/weather
-- command adapted from Dave Taylor's "Wicked Cool Shell Scripts"
-- @ http://www.intuitive.com/wicked/showscript.cgi?063-weather.sh
weatherhook = timer { timeout = 1800 }
weatherhook:add_signal("timeout", function()
    os.execute("wget -q -O - http://wwwa.accuweather.com/adcbin/public/local_index_print.asp?zipcode=73071 | sed -n '/Start - Forecast Cell/,/End - Forecast Cell/p' | sed 's/<[^>]*>//g; s/^ [ ]*//g; s/&copy;/(c) /; s/&amp;/and/' | uniq | head -38 > /tmp/weather")
end)
weatherhook:start()

-- vim:ts=4 sw=4 sts=4 et
