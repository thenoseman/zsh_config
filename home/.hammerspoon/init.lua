local log = hs.logger.new('zsh_config','debug')
local secondaryDisplayname = "Dell"

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
local secondaryDisplay = hs.screen.find(secondaryDisplayname)
local primaryScreenFrame = primaryDisplay:frame()
if not secondaryDisplay == nil then
  local secondaryScreenFrame = secondaryDisplay:frame()
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

-- Returns the best mode for usage on a screen returns a table with w and h
-- to be used with hs.screen:setMode()
function bestModeForScreen(screenName)
  local sc = hs.screen.find(screenName)
  local allModes = sc:availableModes()
  local modes = {}
  local i = 0

  local oldW = 0
  local oldH = 0

  for mode, _ in pairs(allModes) do 
    local w = tonumber(string.match(mode, "^(%d+)x"))
    local h = tonumber(string.match(mode, "x(%d+)@"))

    if((w > oldW) or (w == oldW and h > oldH)) then
      oldW = w
      oldH = h
    end

    modes[i] = mode 
    i = i + 1 
  end

  return { w = oldW, h = oldH, screen = sc }
end

-- Screen resizing
function onScreenLayoutChange()
  local secondaryDisplayMode = bestModeForScreen(secondaryDisplayname)
--  secondaryDisplayMode.screen:setMode(secondaryDisplayMode.w, secondaryDisplayMode.h, 1)
  log.i("onScreenLayoutChange triggered rescaling to W:" .. secondaryDisplayMode.w .. " H:" .. secondaryDisplayMode.h)
end

if not secondaryDisplay == nil then
  screenWatcher = hs.screen.watcher.new(onScreenLayoutChange);
  screenWatcher:start()
  log.i("Started screenWatcher")
end
