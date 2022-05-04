-- 
-- Audio functions and callbacks
--
local log = hs.logger.new('audio.lua','debug')
local headset_name = "Jabra Talk 30"
local connection_sound = hs.sound.getByFile(hs.fs.pathToAbsolute("~/.hammerspoon/gem.mp3"))

function onaudiodevicechange(event)
  log.i("AUDIO EVENT: " .. event)
  if event == "dev#" then
    headset = hs.audiodevice.findDeviceByName(headset_name)

    if headset ~= nil then
      --- headset as OUTPUT
      log.i("Headset " .. headset_name .." appeared: Setting as default output")
      headset:setDefaultOutputDevice()
      headset:setVolume(100)

      -- Build in mic as INPUT
      log.i("Setting build in mic as input")
      mic = hs.audiodevice.findDeviceByName("Built-in Microphone")
      mic:setDefaultInputDevice()

      -- play sound
      hs.timer.doAfter(1, function() 
        connection_sound:play()
      end)
      
    end
  end
end


hs.audiodevice.watcher.setCallback(onaudiodevicechange)
hs.audiodevice.watcher.start()
