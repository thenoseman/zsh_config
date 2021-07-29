local log = hs.logger.new('mediakeys.lua','debug')

--
-- Stop mediakeys to start apple apps
--
local tap = hs.eventtap.new({hs.eventtap.event.types.systemDefined}, function (event)
  local data = event:systemKey()
  if data["key"] ~= "PLAY" and data["key"] ~= "FAST" and data["key"] ~= "REWIND" then
     return false, nil
  end
  log.i("Ignoring mediakey " .. data["key"])
  return true, nil
end)
tap:start()

