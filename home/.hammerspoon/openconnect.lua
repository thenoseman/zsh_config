--
-- Shows the status of openconnect
-- 
local log = hs.logger.new('openconnect','debug')
local status_line_bar = nil 
local task = nil

function open_connect_running(exitcode)
  log.i(exitcode)
  if exitcode == 0 then
    status_line_bar = hs.menubar.new()
    status_line_bar:setTitle("☎️")
    status_line_bar:setTooltip("openconnect is running!")
  else
    status_line_bar:delete()
  end
  task:terminate()
end

hs.timer.doEvery(30, function()
  task = hs.task.new("/usr/bin/pgrep", open_connect_running, { "openconnect" }):start()
end)
