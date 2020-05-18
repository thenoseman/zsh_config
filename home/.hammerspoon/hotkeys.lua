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

-- shift + cmd + m
k = hs.hotkey.modal.new('cmd-shift', 'm') 
k:bind('', 'escape', function() k:exit() end) 

-- ¯\_(ツ)_/¯
k:bind('', 'S', nil, function() 
  hs.eventtap.keyStrokes('¯\\_(ツ)_/¯')
end)
