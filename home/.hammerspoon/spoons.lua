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
-- Clipboardtools
--
hs.loadSpoon("ClipboardTool")
spoon.ClipboardTool:bindHotkeys({ show_clipboard = { { "cmd", "shift" }, "v" } })
spoon.ClipboardTool.paste_on_select = true
spoon.ClipboardTool.show_in_menubar = false
spoon.ClipboardTool.max_entry_size = 20000
spoon.ClipboardTool.max_size = true
spoon.ClipboardTool:start()

--
-- Seal
--
if not hs.hotkey.assignable({ "cmd" }, "Space") then
  hs.alert("CMD+SPACE hotkey not assignable. Remove as spotlight search hotkey")
end
hs.loadSpoon("Seal")
spoon.Seal:bindHotkeys({ show = { { "cmd" }, "Space" } })
spoon.Seal:loadPlugins({ "apps", "calc", "nodedocs", "awsjsdocs", "awstfdocs" })
spoon.Seal:start()
