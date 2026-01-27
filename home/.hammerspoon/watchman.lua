local logger = require("hs.logger").new("👁️", "debug")
--
-- Remove watchman watches on boot
-- Otherwise watchman will take up a lot of memory
--
hs.timer.doAfter(1, function()
  logger.i("[WATCHMAN] watch-del-all")
  hs.task.new("/opt/homebrew/bin/watchman", nil, { "watch-del-all" }):start()
end)
