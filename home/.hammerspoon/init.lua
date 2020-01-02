local log = hs.logger.new('home','debug')

-- ReloadConfiguration
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

-- Clipboardtools
hs.loadSpoon("ClipboardTool")
local cliboardtool_hotkeys = { 
  show_clipboard = {{"cmd", "shift"}, "v"}
}
spoon.ClipboardTool:bindHotkeys(cliboardtool_hotkeys)
spoon.ClipboardTool.paste_on_select = true
spoon.ClipboardTool.show_in_menubar = false
spoon.ClipboardTool:start()

-- Screen/ Window movement
hs.window.animationDuration = 0

-- Notice that hammerspoon regards desktop = all screens combined = continguous X coordinates starting top left on primary screen
local primaryDisplay = hs.screen.primaryScreen()
local secondaryDisplay = hs.screen'Dell'
local primaryScreenFrame = primaryDisplay:frame()
local secondaryScreenFrame = secondaryDisplay:frame()

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

-- Standard layout
hs.hotkey.bind({"cmd", "shift"}, "9", function()
  local windowLayout = {
    {"Google Chrome", nil, primaryDisplay, { x = 0, y = 0, w = 0.66, h = 1}, nil, nil},
    {"MacVim", nil, primaryDisplay, { x = 0, y = 0, w = 0.66, h = 1}, nil, nil},
    {"iTerm2", nil, primaryDisplay, { x = 0.66, y = 0, w = 0.34, h = 1}, nil, nil},
    {"Microsoft Outlook", nil, secondaryDisplay, { x = 0.34, y = 0, w = 0.66, h = 1}, nil, nil},
    {"Slack", nil, secondaryDisplay, { x = 0, y = 0, w = 0.34, h = 1}, nil, nil},
  }
  hs.layout.apply(windowLayout)
end)
