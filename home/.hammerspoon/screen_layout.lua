local log = hs.logger.new("screen_layout", "debug")

-- Screen/ Window movement
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
-- selene: allow(unscoped_variables)
primaryDisplay = hs.screen.primaryScreen()
log.i("Primary display  : " .. primaryDisplay:name())

-- Detect Secondary display
local primary_display_lower = string.lower(primaryDisplay:name())
-- selene: allow(unscoped_variables)
secondaryDisplay = hs.fnutils.find(hs.screen.allScreens(), function(display)
	local dname = string.lower(display:name())
	-- Secondary = NOT primary and not "Built-in"
	return string.find(dname, primary_display_lower, 1, true) == nil and string.find(dname, "built-in", 1, true) == nil
end)

local secondaryScreenFrame = { x = 0, y = 0, w = 0, h = 0 }
if not not secondaryDisplay then
	log.i("Secondary display: " .. secondaryDisplay:name())
	secondaryScreenFrame = secondaryDisplay:frame()
else
	log.i("Secondary display: NONE")
end

-- { "fmbp.fritz.box", "localhost" }
-- All non numeric or alpha chars are replaced by "-"
-- hostname "a-b.c" becomes "a-b-c.lua" as an include file
local layout_file = hs.host.names()[1]:gsub("[^a-z0-9]", "-")
log.i("Looking for '" .. os.getenv("HOME") .. "/.hammerspoon/layout/" .. layout_file .. ".lua'")

-- selene: allow(undefined_variable)
if not file_exists(os.getenv("HOME") .. "/.hammerspoon/layout/" .. layout_file .. ".lua") then
	layout_file = "default"
end
log.i("Using config '" .. layout_file .. "'")
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
