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
local primaryDisplay = hs.screen.primaryScreen()
local secondaryDisplay = hs.screen.find(secondaryDisplayname)
local primaryScreenFrame = primaryDisplay:frame()
if not not secondaryDisplay then
  secondaryScreenFrame = secondaryDisplay:frame()
end

-- 2/3 screen size, anchor top left, screen 1
hs.hotkey.bind({"cmd", "shift"}, "1", function()
  local focusedWindow = hs.window.focusedWindow()
  focusedWindow:move({x = 0, y = 0, w = 0.66, h = 1})
end)

-- 1/3 screen size, anchor at 2/3 width, screen 1
hs.hotkey.bind({"cmd", "shift"}, "2", function()
  local focusedWindow = hs.window.focusedWindow()
  focusedWindow:move({x = 0.66, y = 0, w = 0.34, h = 1})
end)

-- 1/3 screen size, anchor top left, screen 2
hs.hotkey.bind({"cmd", "shift"}, "3", function()
  local focusedWindow = hs.window.focusedWindow()
  focusedWindow:move({x = secondaryScreenFrame.x, y = 0, w = secondaryScreenFrame.w / 3, h = secondaryScreenFrame.h})
end)

-- 2/3 screen size, anchor top right, screen 2
hs.hotkey.bind({"cmd", "shift"}, "4", function()
  local focusedWindow = hs.window.focusedWindow()
  focusedWindow:move({x = secondaryScreenFrame.x + secondaryScreenFrame.w / 3, y = 0, w = (secondaryScreenFrame.w / 3) * 2, h = secondaryScreenFrame.h})
end)

-- 2/3 screen size, anchor top right, screen 1
hs.hotkey.bind({"cmd", "shift"}, "5", function()
  local focusedWindow = hs.window.focusedWindow()
  focusedWindow:move({x = 0.34, y = 0, w = 0.66, h = 1})
end)

-- 1/2 screen size, anchor top left, screen 1
hs.hotkey.bind({"cmd", "shift"}, "6", function()
  local focusedWindow = hs.window.focusedWindow()
  focusedWindow:move({x = 0.0, y = 0, w = 0.50, h = 1})
end)

-- 1/2 screen size, anchor top right, screen 1
hs.hotkey.bind({"cmd", "shift"}, "7", function()
  local focusedWindow = hs.window.focusedWindow()
  focusedWindow:move({x = 0.5, y = 0, w = 0.50, h = 1})
end)

-- Standard layout
-- Secodnary sits LEFT of the primary
hs.hotkey.bind({"cmd", "shift"}, "9", function()
  local windowLayout = {
    {"Brave Browser", nil, primaryDisplay, { x = 0, y = 0, w = 0.66, h = 1}, nil, nil},
    {"MacVim", nil, primaryDisplay, { x = 0, y = 0, w = 0.66, h = 1}, nil, nil},
    {"iTerm2", nil, primaryDisplay, { x = 0.66, y = 0, w = 0.34, h = 1}, nil, nil},
    {"Brave Browser", "E-Mail", secondaryDisplay, { x = 0, y = 0, w = 0.66, h = 1}, nil, nil},
    {"Microsoft Outlook", nil, secondaryDisplay, { x = 0, y = 0, w = 0.66, h = 1}, nil, nil},
    {"Slack", nil, secondaryDisplay, { x = 0.66, y = 0, w = 0.34, h = 1}, nil, nil},
    {"Microsoft Teams", nil, secondaryDisplay, { x = 0.66, y = 0, w = 0.34, h = 1}, nil, nil},
  }
  hs.layout.apply(windowLayout, windowTitleComparator)
end)

-- Screen resizing
function onScreenLayoutChange()
  local secondaryDisplay = hs.screen.find(secondaryDisplayname)
  secondaryDisplay:setMode(secondaryDisplayMode.w, secondaryDisplayMode.h, 1)
end

if not not secondaryDisplay then
  screenWatcher = hs.screen.watcher.new(onScreenLayoutChange);
  screenWatcher:start()
end
