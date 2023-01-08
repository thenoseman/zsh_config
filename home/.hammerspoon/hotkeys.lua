local log = hs.logger.new("🔥", "debug")

--
-- hammerspoon window inspector
--
hs.hotkey.bind({ "cmd", "shift" }, "ß", function()
  local focusedWindow = hs.window.focusedWindow()
  local data = {
    window = {
      id = focusedWindow:id(),
      title = focusedWindow:title(),
      subrole = focusedWindow:subrole(),
      role = focusedWindow:role(),
    },
    application = {
      name = focusedWindow:application():name(),
      title = focusedWindow:application():title(),
      bundleID = focusedWindow:application():bundleID(),
    },
  }
  log.i(hs.inspect.inspect(data))
end)
