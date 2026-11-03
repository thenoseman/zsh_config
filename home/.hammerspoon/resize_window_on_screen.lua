--
-- RESIZES a window if it is dragged to a specific screen
--
-- uses primaryDisplay (which is a hs.screen) from screen_layout.lua
--
local log = hs.logger.new("🖥", "debug")
local appname_for_trigger = "Microsoft Teams"
local window_title_for_trigger = "| Microsoft Teams" -- The apps window title to watch for changes, partial match
local window_min_width_to_trigger = 600 -- How wide must the window be to trigger the layout? Small windows should not triggered it.
local border = 60 -- The border/margin to leave around the window

-- Event-driven window filter (no polling!)
-- Use setAppFilter to filter by app name, then filter by title in the callback
local windowFilter = hs.window.filter.new()
windowFilter:setAppFilter(appname_for_trigger, true) -- true = allowApp

local function resizeWindowIfOnScreen(window)
  if window == nil then
    return
  end

  -- Filter by title pattern
  if not window:title() or not string.match(window:title(), window_title_for_trigger) then
    return
  end

  if window:size().w < window_min_width_to_trigger then
    return
  end

  local screenWindowIsOn = window:screen()

  -- Resize only if dragged on primaryDisplay
  if screenWindowIsOn == primaryDisplay then
    log.i("Moving and resizing window '" .. appname_for_trigger .. "'")
    window:setFrameWithWorkarounds({
      x = border,
      y = border,
      w = screenWindowIsOn:frame().w - border * 2,
      h = screenWindowIsOn:frame().h - border,
    })
    window:centerOnScreen()

    -- Remove callback to avoid redundant work
    windowFilter:removeCallback(resizeWindowIfOnScreen)
  end
end

local function applicationWatcher(appName, eventType)
  -- App focused: install window filter callback
  if eventType == hs.application.watcher.activated and appName == appname_for_trigger then
    log.i("Installing window filter callback for '" .. appname_for_trigger .. "'")
    windowFilter:addCallback(resizeWindowIfOnScreen)
    windowFilter:start()
  end

  -- App lost focus or terminated: remove callback
  if
    appName == appname_for_trigger
    and (eventType == hs.application.watcher.deactivated or eventType == hs.application.watcher.terminated)
  then
    log.i("Removing window filter callback for '" .. appname_for_trigger .. "'")
    windowFilter:stop()
    windowFilter:removeCallback(resizeWindowIfOnScreen)
  end
end

holdreference.appWatcherTeamsScreen = hs.application.watcher.new(applicationWatcher)
holdreference.appWatcherTeamsScreen:start()

--- If already running:
if hs.application.find("com.microsoft.teams2") ~= nil then
  applicationWatcher(appname_for_trigger, hs.application.watcher.activated)
end
