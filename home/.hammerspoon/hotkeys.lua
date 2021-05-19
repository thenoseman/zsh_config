local log = hs.logger.new('hotkey.lua','debug')

--
-- hammerspoon window inspector
--
hs.hotkey.bind({"cmd", "shift"}, "ß", function()
  local focusedWindow = hs.window.focusedWindow()
  local data = {
    window = {
      id = focusedWindow:id(),
      title = focusedWindow:title(),
    },
    application = {
      name = focusedWindow:application():name(),
      title = focusedWindow:application():title()
    }
  }
  log.i(hs.inspect.inspect(data))
end)
