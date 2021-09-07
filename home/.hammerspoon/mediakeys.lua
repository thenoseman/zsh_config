local log = hs.logger.new('mediakeys','debug')
local cmus_socket_path = hs.fs.pathToAbsolute("~/.config/cmus/socket")
local cmus_remote_socket = hs.socket.new():connect(cmus_socket_path)
local key_to_command = {
  ["PLAY"] = "player-pause",
  ["FAST"] = "player-next",
  ["REWIND"] = "player-prev",
}

--
-- Stop mediakeys to start apple apps
--
local tap = hs.eventtap.new({hs.eventtap.event.types.systemDefined}, function (event)
  local data = event:systemKey()
  if data["key"] ~= "PLAY" and data["key"] ~= "FAST" and data["key"] ~= "REWIND" then
     return false, nil
  end

  if not data["down"] then
    if cmus_remote_socket == nil then
      log.i("No socket present in " .. cmus_socket_path)
      return true, nil
    end

    local command=key_to_command[data["key"]]
    log.i("Sending command '" .. command .. "' to cmus socket")
    cmus_remote_socket:send(command .. "\n")
  end
  return true, nil
end)
tap:start()

