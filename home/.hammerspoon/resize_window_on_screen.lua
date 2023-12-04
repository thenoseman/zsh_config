-- RESIZES a window if it is dragged to a specific screen
--
-- uses primaryDisplay (which is a hs.screen) from screen_layout.lua
--
local log = hs.logger.new("🖥", "debug")
local appname_for_trigger = "Microsoft Teams (work or school)"
local window_title_for_trigger = "| Microsoft Teams" -- The apps window title to watch for changes, partial match
local window_min_width_to_trigger = 600 -- How wide must the window be to trigger the layout? Small windows should not triggered it.

-- selene: allow(undefined_variable)
local resizeIfDraggedToScreen = primaryDisplay

local timer = nil
local testIntervalSec = 1 -- How long to wait until running the resize function?
local border = 30 -- The border/margin to leave around the window

function resizeWindowIfOnScreen(window)
  if window == nil or window:size().w < window_min_width_to_trigger then
    return
  end

  local screenWindowIsOn = window:screen()

  -- selene: allow(undefined_variable)
  if screenWindowIsOn == resizeIfDraggedToScreen then
    log.i("Moving and resizing window '" .. appname_for_trigger .. "'")
    window:setFrameWithWorkarounds({
      x = border,
      y = border,
      w = screenWindowIsOn:frame().w - border * 2,
      h = screenWindowIsOn:frame().h - border,
    })
    window:centerOnScreen()

    -- Remove timer
    timer:stop()
    timer = nil
  end
end

function applicationWatcher(appName, eventType)
  -- App focused and no UI watcher installed
  if timer == nil and eventType == hs.application.watcher.activated and appName == appname_for_trigger then
    local window = hs.window.find(window_title_for_trigger)
    timer = hs.timer.doEvery(testIntervalSec, function()
      resizeWindowIfOnScreen(window)
    end)
  end

  -- App lost focus or terminated
  if
    appName == appname_for_trigger
    and (eventType == hs.application.watcher.deactivated or eventType == hs.application.watcher.terminated)
  then
    -- Remove timer
    if timer then
      timer:stop()
      timer = nil
    end
  end
end

-- selene: allow(unscoped_variables)
appWatcherTeamsScreen = hs.application.watcher.new(applicationWatcher)
appWatcherTeamsScreen:start()

--- If already running:
if hs.application.find("com.microsoft.teams2") ~= nil then
  applicationWatcher(appname_for_trigger, hs.application.watcher.activated)
end
