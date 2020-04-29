--
-- MS Teams mute by pressing ESCAPE
--
local input_device = hs.audiodevice.defaultInputDevice()
local menubar = nil
local appname_for_trigger = "Microsoft Teams"
local canvas = nil

-- Mut/Unmute Mic
function toggleInputMuted()
  hs.eventtap.event.newKeyEvent({"shift", "cmd"}, "m", true):post(hs.application.find(appname_for_trigger))
  hs.timer.doAfter(0.5, showTeamsMuteState)
end

--
-- Hotkey
-- 
local teamsHotkey = hs.hotkey.new("", "escape", nil, toggleInputMuted, nil, nil)

--
-- Install watcher for MS Teams
--
function applicationWatcher(appName, eventType)
  -- App focused
  if (eventType == hs.application.watcher.activated) then
    if (appName == appname_for_trigger) then
      teamsHotkey:enable()
      if canvas then
        canvas:show()
      end
    end
  end

  -- App lost focus
  if (eventType == hs.application.watcher.deactivated) then
    if (appName == appname_for_trigger) then
      teamsHotkey:disable()
    end
  end

  -- App terminated
  if (eventType == hs.application.watcher.terminated) then
    if (appName == appname_for_trigger) then
      teamsHotkey:disable()
      if canvas then
        canvas:hide()
      end
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
  local snapWidth = 50 
  local snapHeight = 50 
  local app = hs.application.find(appname_for_trigger)
  local window = app:mainWindow()
  local frame = window:frame()
  local screen = window:screen()
  local canvasX = screen:currentMode().w  - snapWidth - 10 
  local canvasY = screen:currentMode().h - snapHeight - 10
  local areaRect = hs.geometry.rect(frame.x + (frame.w / 2) - 60, frame.y + frame.h - 180, snapWidth, snapHeight)
  local snapshot = screen:snapshot(areaRect)

  if canvas then
    canvas:delete()
  end

  canvas = hs.canvas.new{x=canvasX, y=canvasY,h=snapHeight * 1.2 ,w=snapWidth * 1.2}:appendElements(
    {action = "fill", fillColor = { alpha = 0.5, green = 1.0  }, type = "rectangle", withShadow = true}, 
    {type = "image", image = snapshot, imageScaling = "none"}
    ):show()
end

hs.hotkey.bind({"cmd", "alt", "shift"}, "x", function()
  if canvas then
    canvas:delete()
    canvas = nil
  end
end);
