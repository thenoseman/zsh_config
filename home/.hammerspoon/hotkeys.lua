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

-- Automatically exit modal after two seconds
function k:entered()
  hs.timer.doAfter(2, function()
    k:exit()
  end)
end

-- ESC exits
k:bind('', 'escape', function() 
  k:exit() 
end) 

-- ¯\_(ツ)_/¯  (S)
k:bind('', 'S', nil, function() 
  hs.eventtap.keyStrokes('¯\\_(ツ)_/¯')
  k:exit()
end)
