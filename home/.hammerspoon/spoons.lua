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
spoon.ClipboardTool:start()

--
-- Seal
--
local seal_user_actions = {
  ["function"] = {
    fn = function()
      hs.alert("function!")
    end,
  },
}

if not hs.hotkey.assignable({ "cmd" }, "Space") then
  hs.alert("CMD+SPACE hotkey not assignable. Remove as spotlight search hotkey")
end
hs.loadSpoon("Seal")
spoon.Seal:bindHotkeys({ show = { { "cmd" }, "Space" } })
spoon.Seal:loadPlugins({ "apps", "calc", "useractions" })
spoon.Seal.plugins.useractions.actions = seal_user_actions
spoon.Seal:start()

--
-- DeepLTranslate
--
hs.loadSpoon("DeepLTranslate")
spoon.DeepLTranslate:bindHotkeys({ translate = { { "cmd", "alt", "ctrl" }, "d" } })
