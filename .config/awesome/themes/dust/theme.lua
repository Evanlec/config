-----------------------------
--     tdy's dust theme    --
--      awesome 3.4.3      --
-- based on Dust GTK theme --
--      <tdy@gmx.com>      --
-----------------------------

theme = {}

theme.font          = "Inconsolata"

theme.bg_normal     = "#222222"
theme.bg_focus      = "#908884"
theme.bg_urgent     = "#cd7171"
theme.bg_minimize   = "#444444"

theme.fg_normal     = "#aaaaaa"
theme.fg_focus      = "#111111"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.border_width  = "1"
theme.border_normal = "#222222"
theme.border_focus  = "#908884"
theme.border_marked = "#91231c"

theme.bg_widget           = "#333333"
theme.fg_widget           = "#908884"
theme.fg_center_widget    = "#636363"
theme.fg_end_widget       = "#ffffff"
theme.fg_off_widget       = "#22211f"

theme.taglist_squares_sel = "/usr/share/awesome/themes/default/taglist/squarefw.png"
theme.taglist_squares_unsel = "/usr/share/awesome/themes/default/taglist/squarew.png"

theme.tasklist_floating_icon = "/usr/share/awesome/themes/default/tasklist/floatingw.png"

theme.menu_submenu_icon = awful.util.getdir("config") .. "/themes/dust/submenu.png"
theme.menu_height   = "15"
theme.menu_width    = "100"

-- Define the image to load
theme.titlebar_close_button_normal = "/usr/share/awesome/themes/default/titlebar/close_normal.png"
theme.titlebar_close_button_focus = "/usr/share/awesome/themes/default/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive = "/usr/share/awesome/themes/default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = "/usr/share/awesome/themes/default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active = "/usr/share/awesome/themes/default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive = "/usr/share/awesome/themes/default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = "/usr/share/awesome/themes/default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active = "/usr/share/awesome/themes/default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive = "/usr/share/awesome/themes/default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = "/usr/share/awesome/themes/default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active = "/usr/share/awesome/themes/default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive = "/usr/share/awesome/themes/default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = "/usr/share/awesome/themes/default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active = "/usr/share/awesome/themes/default/titlebar/maximized_focus_active.png"

theme.wallpaper_cmd = { "xsetroot -cursor_name left_ptr" }

theme.layout_fairh      = awful.util.getdir("config") .. "/themes/dust/layouts/fairhw.png"
theme.layout_fairv      = awful.util.getdir("config") .. "/themes/dust/layouts/fairvw.png"
theme.layout_floating   = awful.util.getdir("config") .. "/themes/dust/layouts/floatingw.png"
theme.layout_magnifier  = awful.util.getdir("config") .. "/themes/dust/layouts/magnifierw.png"
theme.layout_max        = awful.util.getdir("config") .. "/themes/dust/layouts/maxw.png"
theme.layout_fullscreen = awful.util.getdir("config") .. "/themes/dust/layouts/fullscreenw.png"
theme.layout_tilebottom = awful.util.getdir("config") .. "/themes/dust/layouts/tilebottomw.png"
theme.layout_tileleft   = awful.util.getdir("config") .. "/themes/dust/layouts/tileleftw.png"
theme.layout_tile       = awful.util.getdir("config") .. "/themes/dust/layouts/tilew.png"
theme.layout_tiletop    = awful.util.getdir("config") .. "/themes/dust/layouts/tiletopw.png"
theme.layout_spiral     = awful.util.getdir("config") .. "/themes/dust/layouts/spiralw.png"
theme.layout_dwindle    = awful.util.getdir("config") .. "/themes/dust/layouts/dwindlew.png"

theme.awesome_icon16 = awful.util.getdir("config") .. "/icons/awesome16-dust.png"
theme.awesome_icon14 = awful.util.getdir("config") .. "/icons/awesome14-dust.png"

theme.widget_cpu = awful.util.getdir("config") .. "/icons/dust/cpu.png"
theme.widget_mem = awful.util.getdir("config") .. "/icons/dust/ram.png"
theme.widget_bat = awful.util.getdir("config") .. "/icons/dust/bat.png"
theme.widget_ac = awful.util.getdir("config") .. "/icons/dust/ac.png"
theme.widget_crit = awful.util.getdir("config") .. "/icons/dust/crit.png"
theme.widget_blank = awful.util.getdir("config") .. "/icons/dust/blank.png"
theme.widget_vol = awful.util.getdir("config") .. "/icons/dust/vol.png"
theme.widget_mute = awful.util.getdir("config") .. "/icons/dust/mute.png"
theme.widget_pac = awful.util.getdir("config") .. "/icons/dust/pac.png"
theme.widget_upg = awful.util.getdir("config") .. "/icons/dust/upg.png"
theme.widget_mail = awful.util.getdir("config") .. "/icons/dust/mail.png"
theme.widget_mailn = awful.util.getdir("config") .. "/icons/dust/mailn.png"
theme.widget_temp = awful.util.getdir("config") .. "/icons/dust/temp.png"
theme.widget_wifi = awful.util.getdir("config") .. "/icons/dust/wifi.png"
theme.widget_nowifi = awful.util.getdir("config") .. "/icons/dust/nowifi.png"
theme.widget_up = awful.util.getdir("config") .. "/icons/dust/up.png"
theme.widget_down = awful.util.getdir("config") .. "/icons/dust/down.png"
theme.widget_weather = awful.util.getdir("config") .. "/icons/dust/weather.png"
theme.widget_mpd = awful.util.getdir("config") .. "/icons/dust/mpd2.png"

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
