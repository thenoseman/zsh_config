local log = hs.logger.new('msteams','debug')

--
-- MS Teams mute by pressing ESCAPE
--
local input_device = hs.audiodevice.defaultInputDevice()
local menubar = nil


function setMenubarIcon()
  is_muted = input_device:inputMuted()
  menubar:setIcon(hs.fs.pathToAbsolute("~/.hammerspoon/ms-teams-" .. tostring(is_muted) .. ".png"))
end

function toggleMsTeamsMute()
  is_muted = input_device:inputMuted()
  input_device:setInputMuted(not is_muted)
  setMenubarIcon()
end

--
-- Hotkey
-- 
local teamsHotkey = hs.hotkey.new("", "escape", nil, toggleMsTeamsMute, nil, nil)

--
-- Install watcher for MS Teams
--
function applicationWatcher(appName, eventType, appObject)
  if (eventType == hs.application.watcher.activated) then
    if (appName == "Microsoft Teams") then

      menubar = hs.menubar.new()
      setMenubarIcon()

      teamsHotkey:enable()
    else
      menubar:delete()
      teamsHotkey:disable()
    end
  end
end
appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

