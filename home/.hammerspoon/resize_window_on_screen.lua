--
-- RESIZES a window if it is dragged to a specific screen
--
-- uses primaryDisplay (which is a hs.screen) from screen_layout.lua
--
local log = hs.logger.new("🖥", "debug")
local appname_for_trigger = "Microsoft Teams"
local window_title_for_trigger = "| Microsoft Teams" -- The apps window title to watch for changes, partial match
local window_min_width_to_trigger = 600 -- How wide must the window be to trigger the layout? Small windows should not triggered it.

local timer = nil
local testIntervalSec = 1 -- How long to wait until running the resize function?
local maxTicksWithoutWindow = 30 -- Stop polling if no matching window is found after this many ticks
local ticksWithoutWindow = 0
local border = 60 -- The border/margin to leave around the window

local function resizeWindowIfOnScreen(window)
  if window == nil then
    ticksWithoutWindow = ticksWithoutWindow + 1
    if ticksWithoutWindow >= maxTicksWithoutWindow then
      log.i("No matching '" .. appname_for_trigger .. "' window found, stopping poll timer")
      if timer then
        timer:stop()
        timer = nil
      end
    end
    return
  end

  if window:size().w < window_min_width_to_trigger then
    return
  end

  local screenWindowIsOn = window:screen()

  -- Resize only if dragged on primarydisplay
  if screenWindowIsOn == primaryDisplay then
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

local function applicationWatcher(appName, eventType)
  -- App focused and no UI watcher installed
  if timer == nil and eventType == hs.application.watcher.activated and appName == appname_for_trigger then
    ticksWithoutWindow = 0
    timer = hs.timer.doEvery(testIntervalSec, function()
      resizeWindowIfOnScreen(hs.window.find(window_title_for_trigger))
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

holdreference.appWatcherTeamsScreen = hs.application.watcher.new(applicationWatcher)
holdreference.appWatcherTeamsScreen:start()

--- If already running:
if hs.application.find("com.microsoft.teams2") ~= nil then
  applicationWatcher(appname_for_trigger, hs.application.watcher.activated)
end
