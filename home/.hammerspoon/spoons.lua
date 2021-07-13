-- ReloadConfiguration
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

-- MouseCircle
hs.loadSpoon("MouseCircle")
spoon.MouseCircle:bindHotkeys({ show = {{"cmd", "shift"}, "´"}})

-- Clipboardtools
hs.loadSpoon("ClipboardTool")
spoon.ClipboardTool:bindHotkeys( { show_clipboard = {{"cmd", "shift"}, "v"} })
spoon.ClipboardTool.paste_on_select = true
spoon.ClipboardTool.show_in_menubar = false
spoon.ClipboardTool.max_size = true
spoon.ClipboardTool:start()
