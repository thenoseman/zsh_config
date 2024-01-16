local logger = hs.logger.new("🏁", "debug")
logger.i("------------------------------------")
logger.i("---------------- INIT --------------")
logger.i("------------------------------------")

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
