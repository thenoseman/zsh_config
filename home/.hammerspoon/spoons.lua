--
-- ReloadConfiguration
--
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

--
-- MouseCircle
--
hs.loadSpoon("MouseCircle")
spoon.MouseCircle:bindHotkeys({ show = { { "cmd", "shift" }, "´" } })

--
-- Clipboardtool based on SQLITE so I can store anything of any size
--
hs.loadSpoon("ClipboardToolSqlite")
spoon.ClipboardToolSqlite:bindHotkeys({ show_clipboard = { { "cmd", "shift" }, "v" } })
spoon.ClipboardToolSqlite:start()

--
-- Seal
--
if not hs.hotkey.assignable({ "cmd" }, "Space") then
  hs.alert("CMD+SPACE hotkey not assignable. Remove as spotlight search hotkey")
end
hs.loadSpoon("Seal")
spoon.Seal:bindHotkeys({ show = { { "cmd" }, "Space" } })
spoon.Seal:loadPlugins({ "apps", "calc", "nodedocs", "awsjsdocs", "awstfdocs", "mdndocs" })
spoon.Seal:start()
