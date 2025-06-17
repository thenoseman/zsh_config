--
-- Screen layout and window mover
--
require("helper")

local log = hs.logger.new("📺", "debug")

-- Screen/ Window movement
hs.window.animationDuration = 0

local secondaryScreenFrame = { x = 0, y = 0, w = 0, h = 0 }
local layout_file = "default"

function windowTitleComparator(actualWindowTitle, targetMatchWindowTitle)
  if actualWindowTitle:find(targetMatchWindowTitle) then
    return true
  else
    return false
  end
end

function width_to_word(width)
  if width > 2000 and width < 3000 then
    return "large"
  end
  -- WQHD
  if width > 3000 then
    return "very_large"
  end
  return "small"
end

--
-- Watch for screen changes and reload config
--
hs.screen.watcher.new(function()
  log.i("Reloading config because screen setup changed")
  hs.reload()
end)

-- Notice that hammerspoon regards desktop = all screens combined = continguous X coordinates starting top left on primary screen
-- primaryDisplay cannot be local
-- selene: allow(unscoped_variables)
primaryDisplay = hs.screen.primaryScreen()
log.i("Primary display  : " .. primaryDisplay:name())

-- Detect Secondary display
-- which should NOT be the build-in
local primary_display_lower = string.lower(primaryDisplay:name())
-- selene: allow(unscoped_variables)
secondaryDisplay = hs.fnutils.find(hs.screen.allScreens(), function(display)
  local dname = string.lower(display:name())
  -- Secondary = NOT primary and not "Built-in"
  return string.find(dname, primary_display_lower, 1, true) == nil and string.find(dname, "built-in", 1, true) == nil
end)

-- If we have NO secondary that is not the build-in display, choose the buildin as secondary
if not secondaryDisplay then
  -- selene: allow(unscoped_variables)
  secondaryDisplay = hs.fnutils.find(hs.screen.allScreens(), function(display)
    local dname = string.lower(display:name())
    -- Secondary should now actually be the buildin
    return string.find(dname, "built-in", 1, true)
  end)
end

if not not secondaryDisplay and primaryDisplay ~= secondaryDisplay then
  log.i("Secondary display: " .. secondaryDisplay:name())
  secondaryScreenFrame = secondaryDisplay:frame()
else
  -- No layout here since we are using only one display
  log.i("Secondary display: NONE")
end

--
-- THREE displays. Assume "built-in" as terniary display.
--
-- selene: allow(unscoped_variables)
terniaryDisplay = nil
if not not secondaryDisplay and not not primaryDisplay and #hs.screen.allScreens() == 3 then
  terniaryDisplay = hs.fnutils.find(hs.screen.allScreens(), function(display)
    local dname = string.lower(display:name())
    return string.find(dname, "built-in", 1, true) ~= nil
  end)
  log.i("Terniary display: " .. terniaryDisplay:name())
end

-- Build name of layout file
-- The build-in screen width is 1280 px so just distinguish between big (eg. DELL) and small (eg. build-in)
layout_file = "primary_"
  .. width_to_word(primaryDisplay:currentMode().w)
  .. "_secondary_"
  .. width_to_word(secondaryDisplay:currentMode().w)

-- In case of three displays:
if not not terniaryDisplay then
  layout_file = layout_file .. "_terniary_buildin"
end

log.i("Looking for '" .. os.getenv("HOME") .. "/.hammerspoon/layout/" .. layout_file .. ".lua'")

-- selene: allow(undefined_variable)
if not file_exists(os.getenv("HOME") .. "/.hammerspoon/layout/" .. layout_file .. ".lua") then
  layout_file = "default"
end
log.i("Using config '" .. layout_file .. "'")
local CONFIG = require("layout." .. layout_file)

--
-- Backgrounbd images are settable via the layout/*.lua files
--

-- selene: allow(undefined_variable)
if CONFIG.desktopImagePathPrimary and file_exists(CONFIG.desktopImagePathPrimary) then
  log.i("Using desktop image for PRIMARY: " .. CONFIG.desktopImagePathPrimary)
  primaryDisplay:desktopImageURL("file://" .. CONFIG.desktopImagePathPrimary)
end

-- selene: allow(undefined_variable)
if CONFIG.desktopImagePathSecondary and file_exists(CONFIG.desktopImagePathSecondary) then
  log.i("Using desktop image for SECONDARY: " .. CONFIG.desktopImagePathSecondary)
  secondaryDisplay:desktopImageURL("file://" .. CONFIG.desktopImagePathSecondary)
end

-- cmd+shift+<trigger> config:
--
-- 1 : 2/3 screen size, anchor top left, screen 1
-- 2 : 1/3 screen size, anchor at 2/3 width, screen 1
-- 3 : 1/3 screen size, anchor top left, screen 2
-- 4 : 2/3 screen size, anchor top right, screen 2
-- 5 : 2/3 screen size, anchor top right, screen 1
-- 6 : 1/2 screen size, anchor top left, screen 1
-- 7 : 1/2 screen size, anchor top right, screen 1
local triggers = {
  ["1"] = { x = 0, y = 0, w = 0.66, h = 1 },
  ["2"] = { x = 0.66, y = 0, w = 0.34, h = 1 },
  ["3"] = { x = secondaryScreenFrame.x, y = 0, w = secondaryScreenFrame.w / 3, h = secondaryScreenFrame.h },
  ["4"] = {
    x = secondaryScreenFrame.x + secondaryScreenFrame.w / 3,
    y = 0,
    w = (secondaryScreenFrame.w / 3) * 2,
    h = secondaryScreenFrame.h,
  },
  ["5"] = { x = 0.34, y = 0, w = 0.66, h = 1 },
  ["6"] = { x = 0.0, y = 0, w = 0.50, h = 1 },
  ["7"] = { x = 0.5, y = 0, w = 0.50, h = 1 },
}
-- Loop and define hotkeys
for trigger, moveConfig in pairs(triggers) do
  hs.hotkey.bind({ "cmd", "shift" }, trigger, function()
    local focusedWindow = hs.window.focusedWindow()
    focusedWindow:move(moveConfig)
  end)
end

-- Standard layout: Defined in layout/*.lua
hs.hotkey.bind({ "cmd", "shift" }, "9", function()
  hs.layout.apply(CONFIG.windowLayout, windowTitleComparator)
end)
