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

-- Window movement
function focusedWindow() 
  local win = hs.window.focusedWindow()
  local windowFrame = win:frame()
  local screen = win:screen()
  local screenFrame = screen:frame()
  return win, windowFrame, screenFrame
end

hs.window.animationDuration = 0

-- 2/3 screen size, anchor top left
hs.hotkey.bind({"cmd", "shift"}, "1", function()
  local win, windowFrame, screenFrame = focusedWindow()
  windowFrame.x = 0
  windowFrame.y = 0
  windowFrame.w = (screenFrame.w / 3) * 2
  windowFrame.h = screenFrame.h
  win:setFrame(windowFrame)
end)

-- 1/3 screen size, anchor at 2/3 width
hs.hotkey.bind({"cmd", "shift"}, "2", function()
  local win, windowFrame, screenFrame = focusedWindow()
  windowFrame.x = (screenFrame.w / 3) * 2
  windowFrame.y = 0
  windowFrame.w = screenFrame.w / 3
  windowFrame.h = screenFrame.h
  win:setFrame(windowFrame)
end)

-- Standard layout
hs.hotkey.bind({"cmd", "shift"}, "9", function()
  local primaryDisplay = hs.screen.primaryScreen()
  local secondaryDisplay = hs.screen'Dell'
  local windowLayout = {
    {"Google Chrome", nil, primaryDisplay, { x = 0, y = 0, w = 0.66, h = 1}, nil, nil},
    {"MacVim", nil, primaryDisplay, { x = 0, y = 0, w = 0.66, h = 1}, nil, nil},
    {"iTerm2", nil, primaryDisplay, { x = 0.66, y = 0, w = 0.34, h = 1}, nil, nil},
    {"Microsoft Outlook", nil, secondaryDisplay, { x = 0.34, y = 0, w = 0.66, h = 1}, nil, nil},
    {"Slack", nil, secondaryDisplay, { x = 0, y = 0, w = 0.34, h = 1}, nil, nil},
  }
  hs.layout.apply(windowLayout)
end)
