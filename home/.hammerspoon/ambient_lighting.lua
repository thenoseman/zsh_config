local log = hs.logger.new('ambient_lighting.lua','debug')

-- Required iterm2 to have been setup with 
-- ctrl+alt+cmd+l => Load color Preset "Light Background"
-- ctrl+alt+cmd+d => Load color Preset "Dark Background"
function ambientLightWatcher()
  local ambient_lux = hs.brightness.ambient();
  local app = hs.appfinder.appFromName("iTerm2")

  if ambient_lux > 4000 then
    hs.eventtap.keyStroke({"ctrl", "alt", "cmd",}, "l", 0, app)
  else
    hs.eventtap.keyStroke({"ctrl", "alt", "cmd",}, "d", 0, app)
  end
end

-- Autoexecute ambient function
hs.timer.doEvery(30, ambientLightWatcher)
