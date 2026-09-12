-- MAIN CONFIGURATIONS
require("nicerice.conf")

-- FUNCTIONS
require("functions")

-- MONITORS
require("nicerice.monitors")

-- CUSTOM
local f = io.open(os.getenv("HOME") .. "/.config/hypr/custom.lua", "r")
if f then
    f:close()
    require("custom")
end

-- HYPRMOD
require("hyprland-gui")
