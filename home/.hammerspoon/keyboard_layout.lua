--
-- Make sure the correct keyboard layout is active
-- Sometimes MacOS will change the layout based onthe app being used
--
local log = hs.logger.new("🔠", "debug")

-- This is the layout name installed via https://software.sil.org/ukelele/
local germanNoDeadKeyMatcher = "German no dead-keys"

function onKeyboardLayoutChange()
  local currentLayout = hs.keycodes.currentLayout()
  log.i("MacOS switched to layout '" .. currentLayout .. "'")
  if currentLayout ~= germanNoDeadKeyMatcher then
    hs.keycodes.setLayout(germanNoDeadKeyMatcher)
  end
end

-- Only load this if there actually is a german no-deadkey layout available
if hs.fnutils.contains(hs.keycodes.layouts(), germanNoDeadKeyMatcher) then
  hs.keycodes.inputSourceChanged(onKeyboardLayoutChange)
  log.i("'" .. germanNoDeadKeyMatcher .. "' keyboard layout found. Installing watcher")
end
