-- Catch errors and fallback to /etc/xdg/awesome/rc.lua if aw.lua fails
-- a la http://www.markurashi.de/dotfiles/awesome/rc.lua

require("awful")
require("naughty")

local rc, err = loadfile(awful.util.getdir("config") .. "/aw.lua")
if rc then
    rc, err = pcall(rc)
    if rc then
        return
    end
end

dofile("/etc/xdg/awesome/rc.lua")

for s = 1,screen.count() do
    mypromptbox[s].text = awful.util.escape(err:match("[^\n]*"))
end

naughty.notify { text = "awesomeWM crashed during startup on " .. os.date("%d%/%m/%Y %T:\n\n") ..  err .. "\n", timeout = 0 }
