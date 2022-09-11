-- 
-- Audio functions and callbacks
--
local headset_name = "Jabra Talk 30"
local default_name = "Built-in Output"

local log = hs.logger.new('audio.lua','debug')
local connection_sound = hs.sound.getByFile(hs.fs.pathToAbsolute("~/.hammerspoon/gem.mp3"))
local output_switcher_menubar = hs.menubar.new()

--
-- Create icon in menubar to quickly toggle between INTERNAL and HEADSET output
--
local volumes = { buildin=18, headset=18 }
                               
local icons = { 
  buildin = hs.image.imageFromPath('bullhorn.png'):setSize({w=18,h=18}), 
  headset=hs.image.imageFromPath('headset.png'):setSize({w=18,h=18})
}

-- Set icon of output switcher
local function output_switcher_menubar_set_title(device)
  output_switcher_menubar:setIcon(icons[device])
  output_switcher_menubar:setTooltip("Audio output device: " .. device)
end

-- Callback when icon is clicked
local function output_switcher_menubar_clicked() 
  local current_output_device_info = hs.audiodevice.current(false)
  default = hs.audiodevice.findOutputByName(default_name)
  headset = hs.audiodevice.findOutputByName(headset_name)

  if current_output_device_info["name"] == default_name then
    -- From BUILDIN -> HEADSET
    volumes.default = default:outputVolume()
    if headset ~= nil then
      headset:setDefaultOutputDevice()
      headset:setVolume(volumes.headset)
      output_switcher_menubar_set_title("headset")
    end
  else
    -- From HEADSET -> BUILDIN
    if headset ~= nil then
      volumes.headset = headset:outputVolume()
    end
    default:setDefaultOutputDevice()
    default:setVolume(volumes.default)
    output_switcher_menubar_set_title("buildin")
  end
end

-- Init output switcher but hide it until the headset connects
output_switcher_menubar_set_title("buildin")
output_switcher_menubar:setClickCallback(output_switcher_menubar_clicked)
output_switcher_menubar:removeFromMenuBar()

--
-- Switch to HEADSET for input + output when connected
--
function onaudiodevicechange(event)
  headset = hs.audiodevice.findDeviceByName(headset_name)
  if event == "dev#" then
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

      output_switcher_menubar_set_title("headset")
      output_switcher_menubar:returnToMenuBar()
    end
  end

  -- Reset menubar icon to default because the headset disconnected 
  if event == "sOut" and headset == nil then
    output_switcher_menubar:removeFromMenuBar()
    output_switcher_menubar_set_title("buildin")
  end
end

hs.audiodevice.watcher.setCallback(onaudiodevicechange)
hs.audiodevice.watcher.start()
