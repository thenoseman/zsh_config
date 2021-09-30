--
-- Shows the status of openconnect
-- 
local log = hs.logger.new('opencon','debug')
local status_line_bar = nil 
local task = nil

function open_connect_running(exitcode, stdout, stderr)
  if status_line_bar ~= nil then
    status_line_bar:delete()
  end
  if string.find(stdout, "1 packets received") ~= nil then
    status_line_bar = hs.menubar.new()
    status_line_bar:setTitle("☎️")
    status_line_bar:setTooltip("openconnect is running!")
  end
  task:terminate()
end

hs.timer.doEvery(30, function()
  task = hs.task.new("/sbin/ping", open_connect_running, { "-c", "3", "-i", "1", "-o", "-t", "5", "10.120.2.45" }):start()
end)
