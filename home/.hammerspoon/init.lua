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

require("app_auto_kill")
require("audio")
require("colima")
require("hotkeys")
require("junk_file_cleaner")
require("keyboard_layout")
require("mediakeys")
require("msteams")
require("resize_window_on_screen")
require("screen_layout")
require("spoons")
require("watchman")
--require("slow_quit")
