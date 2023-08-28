--
-- Audio functions and callbacks
--
local headsets_user_internal_mic_mapping = {
  ["Jabra Talk 30"] = true,
  ["Poly V4320 Series"] = true,
  ["USB Audio Device"] = true,
}
local buildin_name = "Built-in Output"
-- selene:allow(unused_variable)
local sound_timer = nil

-- "buildin" might be another name
local device = hs.audiodevice.findOutputByName(buildin_name)
if device == nil then
  buildin_name = "MacBook Pro-Lautsprecher"
end

local log = hs.logger.new("🔈", "debug")
local connection_sound = hs.sound.getByFile(hs.fs.pathToAbsolute("~/.hammerspoon/gem.mp3"))
local output_switcher_menubar = hs.menubar.new()
log.i("Buildin output name is '" .. buildin_name .. "'")

--
-- Create icon in menubar to quickly toggle between INTERNAL and HEADSET output
--
local volumes = { buildin = 18, headset = 18 }

local icons = {
  buildin = hs.image.imageFromPath("bullhorn.png"):setSize({ w = 18, h = 18 }),
  headset = hs.image.imageFromPath("headset.png"):setSize({ w = 18, h = 18 }),
}

local output_switcher_menubar_set_title = function()
  return
end

local function output_headset()
  local headset
  local use_internal_mic

  for headset_name, internal_mic in pairs(headsets_user_internal_mic_mapping) do
    headset = hs.audiodevice.findOutputByName(headset_name)
    if headset then
      use_internal_mic = internal_mic
      break
    end
  end

  return headset, use_internal_mic
end

-- Callback when icon is clicked
local function output_switcher_menubar_clicked()
  local current_output_device_info = hs.audiodevice.current(false)
  local buildin = hs.audiodevice.findOutputByName(buildin_name)
  local headset, _ = output_headset()

  if current_output_device_info["name"] == buildin_name then
    -- From BUILDIN -> HEADSET
    log.i("From BUILDIN -> HEADSET '" .. headset:name() .. "'")
    volumes.buildin = buildin:outputVolume()
    if headset ~= nil then
      headset:setDefaultOutputDevice()
      headset:setVolume(volumes.headset)
      output_switcher_menubar_set_title("headset")
    end
  else
    -- From HEADSET -> BUILDIN
    log.i("From HEADSET '" .. headset:name() .. "' -> BUILDIN")
    if headset ~= nil then
      volumes.headset = headset:outputVolume()
    end
    buildin:setDefaultOutputDevice()
    buildin:setVolume(volumes.buildin)
    output_switcher_menubar_set_title("buildin")
  end
end

-- Set icon of output switcher
output_switcher_menubar_set_title = function(a_device)
  output_switcher_menubar:setIcon(icons[a_device])
  output_switcher_menubar:setTooltip("Audio output device: " .. a_device)
  output_switcher_menubar:setClickCallback()
  output_switcher_menubar:setClickCallback(output_switcher_menubar_clicked)
end

-- Init output switcher but hide it until the headset connects
output_switcher_menubar_set_title("buildin")

-- If the headset is not already connected
local the_headset, _ = output_headset()
if the_headset == nil then
  output_switcher_menubar:removeFromMenuBar()
else
  output_switcher_menubar_set_title("headset")
end

--
-- Switch to HEADSET for input + output when connected
--
function onaudiodevicechange(event)
  local headset, use_internal_mic = output_headset()

  if event == "dev#" then
    if headset ~= nil then
      --- headset as OUTPUT
      log.i("Headset " .. headset:name() .. " appeared: Setting as output")
      headset:setDefaultOutputDevice()
      headset:setVolume(100)

      if use_internal_mic then
        -- Build in mic as INPUT
        local mic = hs.audiodevice.findDeviceByName("Built-in Microphone")
        if mic == nil then
          mic = hs.audiodevice.findDeviceByName("MacBook Pro-Mikrofon")
        end
        log.i("Setting '" .. mic:name() .. "' mic as input")
        mic:setDefaultInputDevice()
      else
        log.i("NOT setting internal mic as input")
      end

      -- Show output switcher (again)
      output_switcher_menubar:returnToMenuBar()
      output_switcher_menubar_set_title("headset")

      -- hs.timer.doEvery(1, function()
      --   log.i("inUse" .. hs.inspect(headset:inUse()))
      --   log.i("uid" .. hs.inspect(headset:uid()))
      --   log.i("outputVolume" .. hs.inspect(headset:outputVolume()))
      --   log.i("isOutputDevice" .. hs.inspect(headset:isOutputDevice()))
      -- end)

      -- Play sound
      sound_timer = hs.timer.doAfter(7, function()
        connection_sound:play()
      end)
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
