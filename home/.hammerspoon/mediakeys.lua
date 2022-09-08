--
-- Hammerspoon script to repurpose the mediakeys REWIND, PLAY and FAST 
-- It will remote control a running cmus (https://cmus.github.io/) and
-- also show the current runnign title for a time in the menubar when using "next" or "previous"
-- 
local log = hs.logger.new('mediakeys','debug')
local cmus_socket_path = nil

-- http://asciimage.org/
local icon = [[ASCII:
.331....
.112....
.442....
...2....
....xx..
...xxxx.
....xx..
........
]]
local status_line_bar = nil
local status_line_timeout_sec = 4

local function show_title_in_menubar(status_line)
  --
  -- Show title in menubar
  --
  if status_line_bar == nil then
    status_line_bar = hs.menubar.new()
    hs.timer.doAfter(status_line_timeout_sec, function() 
      status_line_bar:delete()
      status_line_bar = nil
    end)
  end
  status_line_bar:setTitle(status_line)
  status_line_bar:setIcon(icon)
end

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

local function receive_data(data)
  local artist=nil
  local title=nil

  for line in data:gmatch("([^\n]*)\n?") do
    if artist == nil then
    artist = string.match(line, "tag artist (.+)")
    end

    if title == nil then
    title = string.match(line, "tag title (.+)")
    end
  end

  show_title_in_menubar(artist .. ": " .. title)
end

local cmus_remote_socket = nil

local key_to_cmus_command = {
  ["PLAY"] = "player-pause",
  ["FAST"] = "player-next",
  ["REWIND"] = "player-prev",
}

--
-- Stop mediakeys to start apple apps and use them for CMUS
--
media_tap = hs.eventtap.new({hs.eventtap.event.types.systemDefined}, function (event)
  local data = event:systemKey()
  if data["key"] ~= "PLAY" and data["key"] ~= "FAST" and data["key"] ~= "REWIND" then
     return false, nil
  end

  -- Key released
  if not data["down"] then
    cmus_socket_path = hs.fs.pathToAbsolute("~/.config/cmus/socket")
    if not cmus_socket_path then
      log.i("cmus socket not found. skipping key.")
      return true, nil
    end

    -- Open the socket
    if not cmus_remote_socket then
      cmus_remote_socket = hs.socket.new(receive_data):connect(cmus_socket_path)
    end

    local command = key_to_cmus_command[data["key"]]
    log.i("Sending command '" .. command .. "' to cmus socket at " .. cmus_socket_path)
    cmus_remote_socket:send(command .. "\n")

    -- Read cmus status to get current title
    -- Delay to find the actual running title
    hs.timer.doAfter(1, function() 
      cmus_remote_socket:send("status\n")
      cmus_remote_socket:read("vol_right")
    end)
  end
  return true, nil
end)
media_tap:start()

-- Call something on tap to keep it alive ... ????
hs.timer.doEvery(15, function() 
  media_tap:isEnabled()
end)

