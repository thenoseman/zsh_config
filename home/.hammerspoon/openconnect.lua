--
-- Shows the status of openconnect
-- 
local log = hs.logger.new('openconnect','debug')
local status_line_bar = nil 
local task = nil

function open_connect_running(exitcode)
  if exitcode == 0 then
    if status_line_bar == nil then
      status_line_bar = hs.menubar.new()
    end
    status_line_bar:setTitle("☎️")
  else
    if status_line_bar ~= nil then
      status_line_bar:delete()
      status_line_bar = nil
    end
  end
  task:terminate()
end

hs.timer.doEvery(30, function()
  task = hs.task.new("/usr/bin/pgrep", open_connect_running, { "openconnect" }):start()
end)
