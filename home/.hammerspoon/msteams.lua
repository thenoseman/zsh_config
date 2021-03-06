--
-- MS Teams mute by pressing ESCAPE
--
local log = hs.logger.new('msteams.lua','debug')
local appname_for_trigger = "Microsoft Teams"

-- Hotkey setup
local teamsHotkey = hs.hotkey.new("", "escape", nil, function()
  -- Must send to the "Helper"
  local app = hs.appfinder.appFromName("Teams Helper")
  hs.eventtap.event.newKeyEvent({"shift", "cmd"}, "m", true):post(app)
end, nil, nil)

--
-- Install watcher for MS Teams
--
function applicationWatcher(appName, eventType)
  -- App focused
  if (eventType == hs.application.watcher.activated) then
    if (appName == appname_for_trigger) then
      log.i("enable")
      teamsHotkey:enable()
    end
  end

  -- App lost focus
  -- App terminated
  if (eventType == hs.application.watcher.deactivated or
      eventType == hs.application.watcher.terminated) then
    if (appName == appname_for_trigger) then
      teamsHotkey:disable()
    end
  end
end

appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

--- If teams is already running:
if (hs.application.find(appname_for_trigger) ~= nil) then
  applicationWatcher(appname_for_trigger, hs.application.watcher.launched)
end
