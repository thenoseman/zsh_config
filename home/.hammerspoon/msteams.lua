--
-- MS Teams mute by pressing ESCAPE
--
--
local appname_for_trigger = "Microsoft Teams"

-- Hotkey setup
local teamsHotkey = hs.hotkey.new("", "escape", nil, function()
  -- Must send to the "Helper"
  local app = hs.application.find("com.microsoft.teams2")
  hs.eventtap.event.newKeyEvent({ "shift", "cmd" }, "m", true):post(app)
end, nil, nil)

--
-- Install watcher for MS Teams
--
function applicationWatcher(appName, eventType)
  -- App focused
  if eventType == hs.application.watcher.activated then
    if string.match(appName, appname_for_trigger) then
      teamsHotkey:enable()
    end
  end

  -- App lost focus
  -- App terminated
  if eventType == hs.application.watcher.deactivated or eventType == hs.application.watcher.terminated then
    if appName and string.match(appName, appname_for_trigger) then
      teamsHotkey:disable()

      -- Teams reserves the mediakeys if focuses
      -- To remedy this we reload the config!
      -- hs.timer.doAfter(5, function ()
      --   hs.reload()
      -- end)
    end
  end
end

-- selene: allow(unscoped_variables)
-- selene: allow(unused_variable)
appWatcherTeams = hs.application.watcher.new(applicationWatcher)
appWatcherTeams:start()

--- If teams is already running:
if hs.appfinder.appFromWindowTitlePattern(appname_for_trigger) ~= nil then
  applicationWatcher(appname_for_trigger, hs.application.watcher.launched)
end
