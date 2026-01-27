local logger = require("hs.logger").new("🏁", "debug")
logger.i("------------------------------------")
logger.i("---------------- INIT --------------")
logger.i("------------------------------------")

local hotkey = require("hs.hotkey")
hotkey.setLogLevel("info")
--hs.console.maxOutputHistory(10)

require("helper")

-- selene: allow(undefined_variable, unscoped_variables, unused_variable)
if file_exists(os.getenv("HOME") .. "/.hammerspoon/secrets.lua") then
  SECRETS = require("secrets")
  logger.i("SECRETS found and available")
  -- Depending on present secrets
  require("translate_via_aws_translate")
else
  logger.i("SECRETS not found")
end

require("spoons")
require("screen_layout")
require("audio")
require("msteams")
require("hotkeys")
require("mediakeys")
require("resize_window_on_screen")
require("colima")
require("app_auto_kill")
require("keyboard_layout")
require("junk_file_cleaner")
--require("slow_quit")

--
-- Remove watchman watches on boot
-- Otherwise watchman will take up a lot of memory
--
hs.timer.doAfter(10, function()
  logger.i("[WATCHMAN] watch-del-all")
  hs.task.new("/opt/homebrew/bin/watchman", nil, { "watch-del-all" }):start()
end)
