local logger = hs.logger.new("🏁", "debug")
logger.i("------------------------------------")
logger.i("---------------- INIT --------------")
logger.i("------------------------------------")

require("helper")

-- selene: allow(undefined_variable, unscoped_variables, unused_variable)
if file_exists(os.getenv("HOME") .. "/.hammerspoon/secrets.lua") then
  SECRETS = require("secrets")
else
  logger.i("SECRETS not found")
end

-- German spotlight names
hs.application.enableSpotlightForNameSearches(true)

require("spoons")
require("screen_layout")
require("audio")
require("msteams")
require("hotkeys")
require("mediakeys")
require("translate")
require("resize_window_on_screen")
