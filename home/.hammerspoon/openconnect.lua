--
-- Shows the status of openconnect
-- 
local log = hs.logger.new('openconnect','debug')
local trigger_dir = "/private/var/run/vpnc"
local trigger_file = trigger_dir .. "/resolv.conf-backup"
local status_line_bar = nil 

-- { "/Volumes/Data/Downloads/test.hammerspoon" }
-- { {
--   itemIsFile = true,
--   itemRemoved = true
-- } }
function handler(paths, flagsTable)
  if paths[1] == trigger_file then
    print(trigger_file)
    print(hs.inspect(paths))
    print(hs.inspect(flagsTable))
    if flagsTable[1]["itemRemoved"] == true then
      log.i(trigger_file .. " was removed")
      if status_line_bar ~= nil then
        status_line_bar:delete()
        status_line_bar = nil
      end
      return
    end

    if flagsTable[1]["itemCreated"] == true then
      log.i(trigger_file .. " was created")
      if status_line_bar == nil then
        status_line_bar = hs.menubar.new()
      end
      status_line_bar:setTitle("☎️")
      return
    end
  end
end
hs.pathwatcher.new(trigger_dir, handler):start();
