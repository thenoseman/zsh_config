require "spoons"
require "screen_layout"
require "audio"
require "msteams"
require "hotkeys"
require "mediakeys"

-- Sometimes HS will just foget its config
hs.timer.doEvery(60, function ()
  hs.reload()
end)
