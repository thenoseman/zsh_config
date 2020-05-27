-- 
-- Audio functions and callbacks
--
local log = hs.logger.new('audio.lua','debug')
local headset_name = "Jabra Talk 30"

function onaudiodevicechange(event)
  if event == "dev#" then
    headset = hs.audiodevice.findDeviceByName(headset_name)

    if headset ~= nil then
      --- headset as OUTPUT
      log.i("Headset " .. headset_name .." appeared: Setting as default output")
      headset:setDefaultOutputDevice()
      headset:setVolume(33)

      -- Build in mic as INPUT
      log.i("Setting build in mic as input")
      mic = hs.audiodevice.findDeviceByName("Built-in Microphone")
      mic:setDefaultInputDevice()

      -- play sound
      hs.speech.new():speak("Kopfhörer verbunden.")
    end
  end
end


hs.audiodevice.watcher.setCallback(onaudiodevicechange)
hs.audiodevice.watcher.start()
