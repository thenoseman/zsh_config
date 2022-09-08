-- 
-- Audio functions and callbacks
--
local log = hs.logger.new('audio.lua','debug')
local headset_name = "Jabra Talk 30"
local default_name = "Built-in Output"
local connection_sound = hs.sound.getByFile(hs.fs.pathToAbsolute("~/.hammerspoon/gem.mp3"))

function onaudiodevicechange(event)
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

--
-- Create icon in menubar to quickly toggle between INTERNAl and HEADSET output
--
local output_switcher = hs.menubar.new()
local volumes = { default=18, headset=18 }

local function output_switcher_clicked() 
  local current_output_device_info = hs.audiodevice.current(false)
  default = hs.audiodevice.findOutputByName(default_name)
  headset = hs.audiodevice.findOutputByName(headset_name)

  if current_output_device_info["name"] == default_name then
    -- From DEFAULT -> HEADSET
    volumes.default = default:outputVolume()
    if headset ~= nil then
      headset:setDefaultOutputDevice()
      headset:setVolume(volumes.headset)
      output_switcher:setTitle("🎧")
    end
  else
    -- From HEADSET -> DEFAULT
    if headset ~= nil then
      volumes.headset = headset:outputVolume()
    end
    default:setDefaultOutputDevice()
    default:setVolume(volumes.default)
    output_switcher:setTitle("🔈")
  end
end

output_switcher:setTitle("🔈")
output_switcher:setClickCallback(output_switcher_clicked);
