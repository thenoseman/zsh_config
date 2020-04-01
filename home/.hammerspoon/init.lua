local log = hs.logger.new('zsh_config','debug')
local secondaryDisplayname = "Dell"
local secondaryDisplayMode = { w = 2560, h = 1440 }

require "audio"
require "msteams"

-- ReloadConfiguration
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

-- MouseCircle
hs.loadSpoon("MouseCircle")
spoon.MouseCircle:bindHotkeys({ show = {{"cmd", "shift"}, "+"}})

-- Clipboardtools
hs.loadSpoon("ClipboardTool")
spoon.ClipboardTool:bindHotkeys( { show_clipboard = {{"cmd", "shift"}, "v"} })
spoon.ClipboardTool.paste_on_select = true
spoon.ClipboardTool.show_in_menubar = false
spoon.ClipboardTool:start()

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

-- Standard layout
hs.hotkey.bind({"cmd", "shift"}, "9", function()
  local windowLayout = {
    {"Google Chrome", nil, primaryDisplay, { x = 0, y = 0, w = 0.66, h = 1}, nil, nil},
    {"Google Chrome", "E-Mail", secondaryDisplay, { x = 0.34, y = 0, w = 0.66, h = 1}, nil, nil},
    {"MacVim", nil, primaryDisplay, { x = 0, y = 0, w = 0.66, h = 1}, nil, nil},
    {"iTerm2", nil, primaryDisplay, { x = 0.66, y = 0, w = 0.34, h = 1}, nil, nil},
    {"Microsoft Outlook", nil, secondaryDisplay, { x = 0.34, y = 0, w = 0.66, h = 1}, nil, nil},
    {"Slack", nil, secondaryDisplay, { x = 0, y = 0, w = 0.34, h = 1}, nil, nil},
    {"Microsoft Teams", nil, secondaryDisplay, { x = 0, y = 0, w = 0.34, h = 1}, nil, nil},
  }
  hs.layout.apply(windowLayout, windowTitleComparator)
end)

-- Screen resizing
function onScreenLayoutChange()
  local secondaryDisplay = hs.screen.find(secondaryDisplayname)
  secondaryDisplay:setMode(secondaryDisplayMode.w, secondaryDisplayMode.h, 1)
  log.i("onScreenLayoutChange triggered rescaling to W:" .. secondaryDisplayMode.w .. " H:" .. secondaryDisplayMode.h)
end

if not not secondaryDisplay then
  screenWatcher = hs.screen.watcher.new(onScreenLayoutChange);
  screenWatcher:start()
  log.i("Started screenWatcher")
end

--
-- hammerspoon window inspector
--

hs.hotkey.bind({"cmd", "shift"}, "ß", function()
  local focusedWindow = hs.window.focusedWindow()
  local data = {
    window = {
      id = focusedWindow:id(),
      title = focusedWindow:title(),
    },
    application = {
      name = focusedWindow:application():name(),
      title = focusedWindow:application():title()
    }
  }
  log.i(hs.inspect.inspect(data))
end)
