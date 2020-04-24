--
-- MS Teams mute by pressing ESCAPE
--
local input_device = hs.audiodevice.defaultInputDevice()
local menubar = nil
local appname_for_trigger = "Microsoft Teams"

-- Update menubar icon
function setMenubarIcon()
  is_muted = input_device:inputMuted()
  local menubar_icon = "🎤"
  local alert_text = hs.styledtext.new("🎤", { font={size=60}})

  if is_muted then
    menubar_icon = "🔇"
    alert_text = hs.styledtext.new("🎤", { font={ size=60}, color=hs.drawing.color.hammerspoon.osx_red, strikethroughStyle=hs.styledtext.lineStyles.thick})
  end
  hs.alert.show(alert_text, nil, nil, 1)
  menubar:setTitle("Mic: " .. menubar_icon)
end

-- Mut/Unmute Mic
function toggleInputMuted()
  is_muted = input_device:inputMuted()
  input_device:setInputMuted(not is_muted)
  setMenubarIcon()
end

--
-- Hotkey
-- 
local teamsHotkey = hs.hotkey.new("", "escape", nil, toggleInputMuted, nil, nil)

--
-- Install watcher for MS Teams
--
function applicationWatcher(appName, eventType)
  -- App activated
  if (eventType == hs.application.watcher.activated) then
    if (appName == appname_for_trigger) then
      teamsHotkey:enable()
    end
  end

  -- App lost focus
  if (eventType == hs.application.watcher.deactivated) then
    if (appName == appname_for_trigger) then
      teamsHotkey:disable()
    end
  end

  -- App launched
  if (eventType == hs.application.watcher.launched) then
    if (appName == appname_for_trigger) then
      menubar = hs.menubar.new()
      setMenubarIcon()
    end
  end

  -- App terminated
  if (eventType == hs.application.watcher.terminated) then
    if (appName == appname_for_trigger) then
      teamsHotkey:disable()
      menubar:delete()
    end
  end
end

appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

--- If teams is already running:
if (hs.application.find(appname_for_trigger) ~= nil) then
  applicationWatcher(appname_for_trigger, hs.application.watcher.launched)
end

--- find the position of the microphon icon, takes a snapshot and shows it
function showTeamsMuteState()
  local log = hs.logger.new('zsh_config','debug')

  local snapWidth = 50 
  local snapHeight = 50 
  local app = hs.application.find(appname_for_trigger)
  local window = app:mainWindow()
  local frame = window:frame()
  local screen = window:screen()
  local canvasX = (screen:currentMode().w  - snapWidth) / 2 
  local canvasY = (screen:currentMode().h - snapHeight) / 2
  local areaRect = hs.geometry.rect(frame.x + (frame.w / 2) + 44, frame.y + frame.h - 100, snapWidth, snapHeight)
  local snapshot = screen:snapshot(areaRect)

  local canvas = hs.canvas.new{x=canvasX, y=canvasY,h=snapHeight * 2,w=snapWidth * 2}:appendElements(
    {action = "fill", fillColor = { alpha = 0.5, green = 1.0  }, type = "rectangle", withShadow = true}, 
    {type = "image", image = snapshot, imageScaling = "none"}
    ):show()
  hs.timer.doAfter(2, function() canvas:delete() end)
end

hs.hotkey.bind({"cmd", "alt", "shift"}, "1", showTeamsMuteState);

