--
-- General hotkeys
--
local log = hs.logger.new("🔥", "debug")

--
-- hammerspoon window inspector
--
hs.hotkey.bind({ "cmd", "shift" }, "ß", function()
  local focusedWindow = hs.window.focusedWindow()
  local app = focusedWindow:application()

  local data = {
    window = {
      id = focusedWindow:id(),
      title = focusedWindow:title(),
      subrole = focusedWindow:subrole(),
      role = focusedWindow:role(),
      tabCount = focusedWindow:tabCount(),
      size_h = focusedWindow:size().h,
      size_w = focusedWindow:size().w,
    },
    application = {
      name = app:name(),
      title = app:title(),
      bundleID = app:bundleID(),
      pid = app:pid(),
      visibleWindows = app:visibleWindows(),
    },
  }
  log.i(hs.inspect.inspect(data))
end)
