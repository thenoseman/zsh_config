local log = hs.logger.new('screen_layout','debug')

-- Screen/ Window movement
local secondaryDisplayname = "Dell"
local secondaryDisplayMode = { w = 2560, h = 1440 }
hs.window.animationDuration = 0

function windowTitleComparator(actualWindowTitle, targetMatchWindowTitle)
  if actualWindowTitle:find(targetMatchWindowTitle) then
    return true
  else
    return false
  end
end

-- Notice that hammerspoon regards desktop = all screens combined = continguous X coordinates starting top left on primary screen
-- primaryDisplay cannot be local
primaryDisplay = hs.screen.primaryScreen()
log.i("Primary display  : " .. primaryDisplay:name())
local primaryScreenFrame = primaryDisplay:frame()

-- Detect Secondary display
secondaryDisplay = hs.fnutils.filter(hs.screen.allScreens(), function(display) 
  return string.find(string.lower(display:name()), string.lower(primaryDisplay:name())) == nil
end)[1]
secondaryScreenFrame = { x = 0, y = 0, w = 0, h = 0 }
if not not secondaryDisplay then
  log.i("Secondary display: " .. secondaryDisplay:name())
  secondaryScreenFrame = secondaryDisplay:frame()
end

-- { "fmbp.fritz.box", "localhost" }
-- dots (".") are replaced by "_" so 
-- hostname "a-b.c" becomes "a-b_c.lua" as an include file
local layout_file = hs.host.names()[1]:gsub("%..*", "") 
if not file_exists(os.getenv("HOME") .. "/.hammerspoon/layout/" .. layout_file .. ".lua") then
  layout_file = "default"
end
log.i("Looked for '" ..  hs.host.names()[1]:gsub("%..*", "") .. "', using config '" .. layout_file .. "'")
local CONFIG = require("layout." .. layout_file)

-- cmd+shift+<trigger> config
--
-- 1 : 2/3 screen size, anchor top left, screen 1
-- 2 : 1/3 screen size, anchor at 2/3 width, screen 1
-- 3 : 1/3 screen size, anchor top left, screen 2
-- 4 : 2/3 screen size, anchor top right, screen 2
-- 5 : 2/3 screen size, anchor top right, screen 1
-- 6 : 1/2 screen size, anchor top left, screen 1
-- 7 : 1/2 screen size, anchor top right, screen 1
local triggers = {
  ["1"] = {x = 0, y = 0, w = 0.66, h = 1},
  ["2"] = {x = 0.66, y = 0, w = 0.34, h = 1},
  ["3"] = {x = secondaryScreenFrame.x, y = 0, w = secondaryScreenFrame.w / 3, h = secondaryScreenFrame.h},
  ["4"] = {x = secondaryScreenFrame.x + secondaryScreenFrame.w / 3, y = 0, w = (secondaryScreenFrame.w / 3) * 2, h = secondaryScreenFrame.h},
  ["5"] = {x = 0.34, y = 0, w = 0.66, h = 1},
  ["6"] = {x = 0.0, y = 0, w = 0.50, h = 1},
  ["7"] = {x = 0.5, y = 0, w = 0.50, h = 1} 
}
-- Loop and define hotkeys
for trigger, moveConfig in pairs(triggers) do
  hs.hotkey.bind({"cmd", "shift"}, trigger, function()
    local focusedWindow = hs.window.focusedWindow()
    focusedWindow:move(moveConfig)
  end)
end

-- Standard layout: Defined in layout/*.lua
hs.hotkey.bind({"cmd", "shift"}, "9", function()
  hs.layout.apply(CONFIG.windowLayout, windowTitleComparator)
end)
